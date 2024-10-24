type ServiceMiddleware func(PowerPointService, log.Logger) PowerPointService

type proxymw struct {
    context.Context
    PowerPointEndpoint endpoint.Endpoint
    PowerPointService
}

func proxyingMiddleware(proxyList string, ctx context.Context, logger log.Logger) ServiceMiddleware {
    if proxyList == "" {
        logger.Log("proxy_to", "none")
        return func(next PowerPointService, logger log.Logger) PowerPointService { return next }
    }
    proxies := split(proxyList)
    logger.Log("proxy_to", fmt.Sprint(proxies))

    return func(next PowerPointService, logger log.Logger) PowerPointService {
        logger.Log("in circuit breaker stuff")
        var (
            qps         = 100 // max to each instance
            publisher   = static.NewPublisher(proxies, factory(ctx, qps, logger), logger)
            lb          = loadbalancer.NewRoundRobin(publisher)
            maxAttempts = 3
            maxTime     = 100 * time.Millisecond
            endpoint    = loadbalancer.Retry(maxAttempts, maxTime, lb)
        )
        return proxymw{ctx, endpoint, next}
    }
}

func factory(ctx context.Context, qps int, logger log.Logger) loadbalancer.Factory {
    return func(instance string) (endpoint.Endpoint, io.Closer, error) {
        var e endpoint.Endpoint
        e = makeCreatePointStoreProxy(ctx, instance, logger)
        e = circuitbreaker.Gobreaker(gobreaker.NewCircuitBreaker(gobreaker.Settings{}))(e)
        e = kitratelimit.NewTokenBucketLimiter(jujuratelimit.NewBucketWithRate(float64(qps), int64(qps)))(e)
        return e, nil, nil
    }
}

func makeCreatePointStoreProxy(ctx context.Context, instance string, logger log.Logger) endpoint.Endpoint {
    var (
        //trying out some new zipkin tracing stuff
        //myHost        = flag.String("host", "localhost:8080", "Host of this service")
        myHost    = "127.0.0.1:8080"
        myService = "PowerPointService"
        myMethod  = "CreatePowerPoints"
        kafkaHost = []string{"192.168.99.100:9092"}
    )

    if !strings.HasPrefix(instance, "http") {
        instance = "http://" + instance
    }
    u, err := url.Parse(instance)
    if err != nil {
        panic(err)
    }
    if u.Path == "" {
        u.Path = "/powerpoint"
    }

    spanFunc := zipkin.MakeNewSpanFunc(myHost, myService, myMethod)
    collector, _ := zipkin.NewKafkaCollector(kafkaHost)

    logger.Log("url parse", u)
    client := httptransport.NewClient(
        "POST",
        u,
        encodeRequest,
        decodePostPowerPointResponse,
        httptransport.SetClientBefore(zipkin.ToRequest(spanFunc)),
    ).Endpoint()

    client = zipkin.AnnotateClient(spanFunc, collector)(client)

    return client
}

func (mw proxymw) CreatePowerPoint(
    ctx context.Context,
    powerpoint PowerPoint,
) (PointStore, error) {
    glog.Infoln("Create power point request from proxy")
    response, err := mw.PowerPointEndpoint(mw.Context, powerpoint)

    if err != nil {
        return PointStore{}, err
    }

    resp := response.(powerPointResponse)

    if resp.Err != "" {
        return resp.V, errors.New(resp.Err)
    }

    return resp.V, nil
}

func split(s string) []string {
    a := strings.Split(s, ",")
    for i := range a {
        a[i] = strings.TrimSpace(a[i])
    }
    return a
}