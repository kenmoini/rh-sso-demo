package main

import (
	"fmt"
	"net/http"
)

// GetProfile
func GetProfile(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		fmt.Fprintf(w, "GET OK")
	}
}

// PostProfile
func PostProfile(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		fmt.Fprintf(w, "POST OK")
	}
}