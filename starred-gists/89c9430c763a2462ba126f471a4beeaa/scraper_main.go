package cloudrun

import (
	"log"
	"net/url"
	"os"
	"path"
	"reflect"
	"strconv"
	"strings"
	"time"

	"github.com/gocolly/colly"
)

type Platform interface {
	crawl(config Config, writer Exporter) *colly.Collector
}

type Item struct {
	title            string
	location         string
	hasExactLocation bool
	price            int
	livingSpace      float64
	rooms            float64
	url              string
	scrapedAt        time.Time
}

type Config struct {
	dataDir          string
	platforms        []Platform
	storage          Storage
	collectorOptions []colly.CollectorOption
}

func (record Item) csvRow() []string {
	return []string{
		record.title,
		record.location,
		strconv.FormatBool(record.hasExactLocation),
		strconv.Itoa(record.price),
		strconv.FormatFloat(record.livingSpace, 'f', -1, 64),
		strconv.FormatFloat(record.rooms, 'f', -1, 64),
		record.url,
		record.scrapedAt.Format(time.RFC3339),
	}
}

func readConfig(params url.Values) Config {
	available := map[string]Platform{
		"ebay_kleinanzeigen": EBayKleinanzeigen{},
		"immobilien_scout":   ImmobilienScout{},
		"immowelt":           Immowelt{},
		"nestpick":           Nestpick{},
	}

	platforms := make([]Platform, 0)
	for name := range available {
		platforms = append(platforms, available[name])
	}

	cache := params.Get("cache") == "1"
	var collectorOptions []colly.CollectorOption
	if cache {
		collectorOptions = append(collectorOptions, colly.CacheDir("cache"))
	}
	platform := params.Get("platform")
	if platform != "" {
		platforms = []Platform{available[platform]}
	}

	bucket, isDefined := os.LookupEnv("GCLOUD_BUCKET")
	if !isDefined {
		log.Fatalln("GCLOUD_BUCKET must be defined")
	}
	date := time.Now().UTC().Format(time.RFC3339)
	storage := GCloudStorage{
		bucket:          bucket,
		destinationPath: date + "/",
	}

	return Config{
		dataDir:          "/tmp/wohnung",
		platforms:        platforms,
		storage:          storage,
		collectorOptions: collectorOptions,
	}
}

func Run(params url.Values) string {
	config := readConfig(params)
	for _, platform := range config.platforms {
		fileName := strings.Split(reflect.TypeOf(platform).String(), ".")[1]
		fileName = path.Join(config.dataDir, fileName+".csv")
		exporter := CSVExporter{fileName: fileName}
		exporter.run(config, platform.crawl)
		config.storage.write(fileName)
	}

	return "it works"
}
