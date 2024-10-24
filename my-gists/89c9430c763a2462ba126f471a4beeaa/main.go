package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	scraper "github.com/Irio/wohnung/scraper"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		err := r.ParseForm()
		if err != nil {
			log.Println(err)
		}
		if r.Method == http.MethodPost {
			fmt.Fprintln(w, scraper.Run(r.Form))
		}
	})
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
