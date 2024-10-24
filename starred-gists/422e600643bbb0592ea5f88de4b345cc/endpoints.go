type endpoints struct {
    postPowerPointEndpoint endpoint.Endpoint
    getPowerPointEndpoint  endpoint.Endpoint
}

func makeEndpoints(s PowerPointService) endpoints {
    return endpoints{
        postPowerPointEndpoint: makePostPowerPointEndpoint(s),
        getPowerPointEndpoint:  makeGetPowerPointEndpoint(s),
    }
}

func (r postPowerPointResponse) error() error { return r.Err }

func makePostPowerPointEndpoint(s PowerPointService) endpoint.Endpoint {
    return func(ctx context.Context, request interface{}) (response interface{}, err error) {
        req := request.(postPowerPointRequest)
        _, e := s.CreatePowerPoints(ctx, req.PowerPoint)
        return postPowerPointResponse{Err: e}, nil
    }
}

func (r getPowerPointResponse) error() error { return r.Err }

func makeGetPowerPointEndpoint(s PowerPointService) endpoint.Endpoint {
    return func(ctx context.Context, request interface{}) (response interface{}, err error) {
        req := request.(getPowerPointRequest)
        p, e := s.GetPowerPoints(ctx, req.ID)
        return getPowerPointResponse{PowerPoint: p, Err: e}, nil
    }
}