type loggingMiddleware struct {
    next   PowerPointService
    logger log.Logger
}

func (mw loggingMiddleware) GetPowerPoints(ctx context.Context, id string) (p PowerPoint, err error) {
    defer func(begin time.Time) {
        mw.logger.Log("method", "GetPowerPoints", "id", id, "took", time.Since(begin), "err", err)
    }(time.Now())
    return mw.next.GetPowerPoints(ctx, id)
}

func (mw loggingMiddleware) CreatePowerPoints(ctx context.Context, powerpoint PowerPoint) (ps PointStore, err error) {
    defer func(begin time.Time) {
        mw.logger.Log("method", "CreatePowerPoints", "powerpoint", powerpoint, time.Since(begin), "err", err)
    }(time.Now())
    return mw.next.CreatePowerPoints(ctx, powerpoint)
}

type instrumentingMiddleware struct {
    PowerPointService
    requestDuration metrics.TimeHistogram
    requestCount    metrics.Counter
    countResult     metrics.Histogram
}

func (mw instrumentingMiddleware) GetPowerPoints(ctx context.Context, id string) (power_point PowerPoint, err error) {
    defer func(begin time.Time) {
        methodField := metrics.Field{Key: "method", Value: "GetPowerPoints"}
        errorField := metrics.Field{Key: "error", Value: fmt.Sprintf("%v", err)}
        mw.requestCount.With(methodField).With(errorField).Add(1)
        mw.requestDuration.With(methodField).With(errorField).Observe(time.Since(begin))
    }(time.Now())

    power_point, err = mw.PowerPointService.GetPowerPoints(ctx, id)
    return power_point, err
}

func (mw instrumentingMiddleware) CreatePowerPoints(ctx context.Context, powerpoint PowerPoint) (point_store PointStore, err error) {
    defer func(begin time.Time) {
        methodField := metrics.Field{Key: "method", Value: "CreatePowerPoints"}
        errorField := metrics.Field{Key: "error", Value: fmt.Sprintf("%v", err)}
        mw.requestCount.With(methodField).With(errorField).Add(1)
        mw.requestDuration.With(methodField).With(errorField).Observe(time.Since(begin))
    }(time.Now())

    point_store, err = mw.PowerPointService.CreatePowerPoints(ctx, powerpoint)
    return point_store, err
}