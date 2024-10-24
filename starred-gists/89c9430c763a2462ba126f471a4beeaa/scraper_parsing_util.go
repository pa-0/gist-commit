package cloudrun

import (
	"strconv"
	"strings"
)

func parsePrice(valueStr string) (int, error) {
	value, err := parseFloat(valueStr, " €")
	return int(value * 100), err
}

func parseSpace(value string) (float64, error) {
	return parseFloat(value, " m²")
}

func parseFloat(valueStr string, unit string) (float64, error) {
	replacer := strings.NewReplacer(",", ".", ".", "", unit, "")
	return strconv.ParseFloat(replacer.Replace(valueStr), 64)
}
