type PowerPointService interface {
    CreatePowerPoints(ctx context.Context, powerpoint PowerPoint) (PointStore, error)
    GetPowerPoints(ctx context.Context, id string) (PowerPoint, error)
}

type inmemService struct {
    mtx       sync.RWMutex
    m         map[string]PowerPoint
    ps_read   *sql.DB
    couchbase *gocb.Bucket
}

var (
    errInconsistentIDs = errors.New("inconsistent IDs")
    errAlreadyExists   = errors.New("already exists")
    errNotFound        = errors.New("not found")
)

func newInmemService(ps_read *sql.DB, couchbase *gocb.Bucket) PowerPointService {
    return &inmemService{
        m:         map[string]PowerPoint{},
        ps_read:   ps_read,
        couchbase: couchbase,
    }
}

func (s *inmemService) CreatePowerPoints(
    ctx context.Context,
    powerpoint PowerPoint,
) (PointStore, error) {
    location, err := time.LoadLocation("America/Denver")
    expiration := uint32(int(now.New(time.Now().In(location)).EndOfQuarter().Unix()))

    details := Rank{6, 7}
    //details.User_id = 6
    //details.Value = 7

    _ = powerpoint

    var db_ids [][]string
    var db_id []string
    db_id = append(db_id, "1")
    db_id = append(db_id, "2")
    db_id = append(db_id, "2")
    db_ids = append(db_ids, db_id)

    point_store := PointStore{
        Object_type: "points_store",
        Customer_id: 1,
        Indicator:   "today",
        Details:     []Rank{details},
        Dashboards:  db_ids,
    }

    couch_key := "custommer_1_points_1"

    _, err = s.couchbase.Upsert(
        couch_key,
        &point_store,
        expiration,
    )

    return point_store, err
}

func (s *inmemService) GetPowerPoints(ctx context.Context, id string) (PowerPoint, error) {
    // replace this with a connection to the database
    // use new config library
    //s.mtx.RLock()
    //defer s.mtx.RUnlock()
    //p, ok := s.m[id]
    //fmt.Println("something")
    //PowerPintoint.Id = id
    //may not need to manage threads here.
    var points float64
    err := s.ps_read.QueryRow("SELECT points FROM user_points WHERE user_id = 1").Scan(&points)
    //err := s.couchbase.Get("pp_customerid_

    switch {
    case err == sql.ErrNoRows:
        log.Printf("No rows")
    case err != nil:
        log.Fatal(err)
    default:
        fmt.Printf("points are %s\n", points)
    }
    //s.mtx.RLock()
    //defer s.mtx.RUnlock()

    p, ok := s.m[id]
    if !ok {
        return PowerPoint{}, errNotFound
    }
    return p, nil
    //return PowerPoint, nil

    // Gets a sum of all the users points for a given date range.
}