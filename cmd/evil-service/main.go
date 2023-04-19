/*
https://github.com/mmcgrana/gobyexample/blob/master/examples/http-server/http-server.go
*/
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/tuxerrante/kapparmor-demo/apis"
	"github.com/tuxerrante/kapparmor-demo/pkg/version"
)

var SERVER_PORT string = os.Getenv("SERVER_PORT")

/*
Start a server on SERVER_PORT exposing:
  - /hello
  - /headers
*/
func main() {
	log.Printf("Service version: %s\n", version.Version)

	http.HandleFunc("/hello", Hello)
	http.HandleFunc("/headers", headers)

	http.ListenAndServe(":"+SERVER_PORT, nil)
}

func Hello(w http.ResponseWriter, req *http.Request) {

	log.Printf("/hello invocation.")
	apis.PrettyFunc()
	fmt.Fprintf(w, "hello")
}

func headers(w http.ResponseWriter, req *http.Request) {

	for name, headers := range req.Header {
		for _, h := range headers {
			fmt.Fprintf(w, "%v: %v\n", name, h)
		}
	}
}

func init() {
	if os.Getenv("SERVER_PORT") == "" {
		panic("No SERVER_PORT variable was defined!")
	}
}
