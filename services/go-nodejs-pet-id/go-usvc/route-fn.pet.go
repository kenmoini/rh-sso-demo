package main

import (
	"fmt"
	"net/http"
)

// GetPet
func GetPet(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		fmt.Fprintf(w, "GET OK")
	}
}

// PostPet
func PostPet(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		fmt.Fprintf(w, "POST OK")
	}
}