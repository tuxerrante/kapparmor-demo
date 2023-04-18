package main

import (
	"log"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestGetHello(t *testing.T) {
	t.Run("Get /hello", func(t *testing.T) {
		request, err := http.NewRequest(http.MethodGet, "/hello", nil)
		checkErr(err)
		response := httptest.NewRecorder()

		Hello(response, request)

		got := response.Body.String()
		want := "hello"
		checkTestResult(t, got, want)
	})
}

func checkTestResult(t *testing.T, got, want any) {
	if got != want {
		t.Errorf("Received %q instead of %q", got, want)
	}
}

func checkErr(err error) {
	if err != nil {
		log.Fatal(err)
	}
}
