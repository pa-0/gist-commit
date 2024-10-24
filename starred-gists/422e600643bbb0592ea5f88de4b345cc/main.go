func main() {
    var (
        httpAddr = flag.String("http.addr", ":8080", "HTTP listen address")
        //not all request have to be proxied... proxies are determined by the proxying middleware
        proxy = flag.String("proxy", "", "Optional comman-separated list of URLs to proxy requests")
    )

    flag.Parse()
    //not sure where loading configuration values should go yet
    //load configuruation values
    glog.Info("Loading configuration")
    ioutil.WriteFile("./somefile", []byte("in main !"), 0644)

    if *token == "unset" {
        glog.Infoln("No vault token provided, using env var.")
        *token = os.Getenv("VAULT_TOKEN")
    }

    err := config.Initialize(*env, *token)

    if err != nil {
        glog.Error(err)
    }

    var conf Configuration
    err = mapstructure.Decode(config.LoadConfig(), &conf)
    if err != nil {
        glog.Errorf("Error loading configuration: %v\n", err)
    }
    glog.Infoln("Configuration loaded: %+v\n", conf)

    // setup SQL database pools
    glog.Info("Initialize Powerstandings read database pool...")
    ps_read, err := psdb.InitNewPool(
        "ps_read",
        conf.Ps_read.Connections,
        conf.Ps_read.Max_idle_connections,conf.Ps_read.Max_open_connections,
    )

    if err != nil {
        glog.Errorf("Error getting database read connection")
    }

    glog.Info(ps_read.Stats())

    glog.Info("Connection to Couchbase cluster...")

    couchbase := couchbase.GetCouch()
    couchbase_coushion, err := couchbase.Init(
        conf.Couchbase.Connections,
        conf.CouchbaseSecrets.Username,
        conf.CouchbaseSecrets.Password,
        conf.Couchbase.Bucket,
        conf.CouchbaseSecrets.BucketPassword,
        conf.Couchbase.DesignDocs,
    )

    if err != nil {
        glog.Errorf("Error initializing couchbase:%v", err)
    }

    fieldKeys := []string{"method", "error"}

    requestCount := kitprometheus.NewCounter(stdprometheus.CounterOpts{
        Namespace: "my_group",
        Subsystem: "powerpoint_service",
        Name:      "request_count",
        Help:      "Number of requests received.",
    }, fieldKeys)
    requestDuration := metrics.NewTimeHistogram(time.Microsecond, kitprometheus.NewSummary(stdprometheus.SummaryOpts{
        Namespace: "my_group",
        Subsystem: "powerpoint_service",
        Name:      "request_latency_microseconds",
        Help:      "Total duration of requests in microseconds.",
    }, fieldKeys))
    countResult := kitprometheus.NewSummary(stdprometheus.SummaryOpts{
        Namespace: "my_group",
        Subsystem: "powerpoint_service",
        Name:      "count_result",
        Help:      "The result of each count method.",
    }, []string{})

    var logger log.Logger
    {
        logger = log.NewLogfmtLogger(os.Stderr)
        logger = log.NewLogfmtLogger(os.Stdout)
        logger = log.NewContext(logger).With("ts", log.DefaultTimestampUTC)
        logger = log.NewContext(logger).With("caller", log.DefaultCaller)
    }
    
        var ctx context.Context
    {
        ctx = context.Background()
    }

    var s PowerPointService
    {
        s = newInmemService(ps_read, couchbase_coushion)
        s = proxyingMiddleware(*proxy, ctx, logger)(s, logger)
        s = loggingMiddleware{s, log.NewContext(logger).With("component", "s")}
        s = instrumentingMiddleware{
            s,
            requestDuration,
            requestCount,
            countResult,
        }
    }

    var h http.Handler
    {
        h = makeHandler(ctx, s, log.NewContext(logger).With("component", "http"))
    }

    errs := make(chan error, 2)
    go func() {
        logger.Log("transport", "http", "address", *httpAddr, "msg", "listening")
        errs <- http.ListenAndServe(*httpAddr, h)
    }()
    go func() {
        c := make(chan os.Signal)
        signal.Notify(c, syscall.SIGINT)
        errs <- fmt.Errorf("$s", <-c)
    }()

    logger.Log("terminated", <-errs)
}