package cloudrun

import (
	"encoding/csv"
	"log"
	"os"
	"path"
	"reflect"

	"github.com/gocolly/colly"
)

type Exporter interface {
	write(record Item) error
}

type CSVExporter struct {
	writer   *csv.Writer
	fileName string
}

func (exp CSVExporter) write(record Item) error {
	return exp.writer.Write(record.csvRow())
}

func (CSVExporter) fields() []string {
	val := reflect.ValueOf(&Item{}).Elem()
	names := make([]string, val.NumField())
	for i := 0; i < val.NumField(); i++ {
		names[i] = val.Type().Field(i).Name
	}
	return names
}

func (exp CSVExporter) run(config Config, fn func(Config, Exporter) *colly.Collector) {
	os.MkdirAll(path.Dir(exp.fileName), 755)
	file, err := os.Create(exp.fileName)
	if err != nil {
		log.Fatalf("Cannot create file %q: %s\n", exp.fileName, err)
		return
	}
	defer file.Close()
	exp.writer = csv.NewWriter(file)
	defer exp.writer.Flush()
	exp.writer.Write(exp.fields())

	collector := fn(config, exp)
	log.Printf("Scraping finished, check file %q for results\n", exp.fileName)
	log.Println(collector)
}
