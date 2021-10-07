package main

import (
	"log"
)

// Func main should be as small as possible and do as little as possible by convention
func main() {
	// Generate our config based on the config supplied
	// by the user in the flags
	cfgPath, err := ParseFlags()
	checkAndFail(err)

	// Run preflight
	PreflightSetup()

	// Setup server config
	cfg, err := NewConfig(cfgPath)
	checkAndFail(err)

	// Run server preflight
	ServerPreflightSetup()

	// Run database preflight
	if cfg.Application.SQLConnection.Database != "" {
		// Setup database connection
		DBPreflightChecks(cfg)
	} else {
		log.Printf("No database configured!\n")
	}

	// Run the server
	cfg.RunHTTPServer()

}