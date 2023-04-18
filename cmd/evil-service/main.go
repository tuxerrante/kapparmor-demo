/*
https://github.com/mmcgrana/gobyexample/blob/master/examples/http-server/http-server.go
*/
package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/tuxerrante/kapparmor-demo/apis"
	"github.com/tuxerrante/kapparmor-demo/pkg/version"
)

// var SERVER_PORT := os.Getenv("SERVER_PORT")
const SERVER_PORT string = "8090"

/*
Start a server on SERVER_PORT exposing:
  - /hello
  - /headers
*/
func main() {
	log.Printf("version: %s\n", version.Version)

	http.HandleFunc("/hello", Hello)
	http.HandleFunc("/headers", headers)

	http.ListenAndServe(":"+SERVER_PORT, nil)
}

func Hello(w http.ResponseWriter, req *http.Request) {

	fmt.Fprintf(w, "hello")
	log.Printf("/hello invocation.")
	apis.PrettyFunc()
}

func headers(w http.ResponseWriter, req *http.Request) {

	for name, headers := range req.Header {
		for _, h := range headers {
			fmt.Fprintf(w, "%v: %v\n", name, h)
		}
	}
}
