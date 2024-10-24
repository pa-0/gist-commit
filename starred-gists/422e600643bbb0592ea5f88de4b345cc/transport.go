func makeHandler(ctx context.Context, s PowerPointService, logger kitlog.Logger) stdhttp.Handler {
    var (
        //trying out some new zipkin tracing stuff
        //myHost        = flag.String("host", "localhost:8080", "Host of this service")
        myHost        = "127.0.0.1:8080"
        myService     = "PowerPointService"
        myMethod      = "CreatePowerPoints"
        myOtherMethod = "GetPowerPoints"
        kafkaHost     = []string{"192.168.99.100:9092"}
    )

    e := makeEndpoints(s)
    r := mux.NewRouter()

    spanFunc := zipkin.MakeNewSpanFunc(myHost, myService, myMethod)
    spanFuncOther := zipkin.MakeNewSpanFunc(myHost, myService, myOtherMethod)
    collector, _ := zipkin.NewKafkaCollector(kafkaHost)
    zipkin.AnnotateServer(spanFunc, collector)(e.postPowerPointEndpoint)
    zipkin.AnnotateServer(spanFuncOther, collector)(e.getPowerPointEndpoint)

    postOptions := []kithttp.ServerOption{
        kithttp.ServerErrorLogger(logger),
        kithttp.ServerErrorEncoder(encodeError),
        kithttp.ServerBefore(
            zipkin.ToContext(spanFunc, logger),
        ),
    }

    getOptions := []kithttp.ServerOption{
        kithttp.ServerErrorLogger(logger),
        kithttp.ServerErrorEncoder(encodeError),
        kithttp.ServerBefore(
            zipkin.ToContext(spanFuncOther, logger),
        ),
    }
    // POST /powerpoint add a new powerpoint
    // GET /powerpoint/:id get specified powerpoints

    r.Methods("POST").Path("/powerpoint").Handler(kithttp.NewServer(
        ctx,
        e.postPowerPointEndpoint,
        decodePostPowerPointRequest,
        encodeResponse,
        postOptions...,
    ))

    r.Methods("GET").Path("/powerpoint/{id}").Handler(kithttp.NewServer(
        ctx,
        e.getPowerPointEndpoint,
        decodeGetPowerPointRequest,
        encodeResponse,getOptions...,
    ))

    r.Handle("/metrics", stdprometheus.Handler())

    return r
}