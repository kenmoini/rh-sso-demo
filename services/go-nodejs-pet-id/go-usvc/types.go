package main

import (
	"time"
)

// errorString is a trivial implementation of error.
type errorString struct {
	s string
}

func (e *errorString) Error() string {
	return e.s
}

// CLIOpts defines the CLI Arguements
type CLIOpts struct {
	Config string
}

// Config struct for webapp config at the top level
type Config struct {
	Application ApplicationYaml `yaml:"app"`
}

// ApplicationYaml is what is defined for this Application when running as a server
type ApplicationYaml struct {
	Server          Server          `yaml:"server,omitempty"`
	KafkaConnection KafkaConnection `yaml:"kafka_connection,omitempty"`
	SQLConnection   SQLConnection   `yaml:"db_connection,omitempty"`
}

// Server configures the HTTP server
type Server struct {
	// Host is the local machine IP Address to bind the HTTP Server to
	Host string `yaml:"host"`

	BasePath string `yaml:"base_path"`

	// Port is the local machine TCP Port to bind the HTTP Server to
	Port    string `yaml:"port"`
	Timeout struct {
		// Server is the general server timeout to use
		// for graceful shutdowns
		Server time.Duration `yaml:"server"`

		// Write is the amount of time to wait until an HTTP server
		// write opperation is cancelled
		Write time.Duration `yaml:"write"`

		// Read is the amount of time to wait until an HTTP server
		// read operation is cancelled
		Read time.Duration `yaml:"read"`

		// Read is the amount of time to wait
		// until an IDLE HTTP session is closed
		Idle time.Duration `yaml:"idle"`
	} `yaml:"timeout"`
}

// KafkaConnection provides connection information to a Kafka cluster
type KafkaConnection struct {
	Server    string `yaml:"server"`
	Port      string `yaml:"port"`
	Topic     string `yaml:"topic"`
	Partition string `yaml:"partition"`
}

// SQLConnection provides connection information to a Database
type SQLConnection struct {
	Server    string `yaml:"server"`
	Port      string `yaml:"port"`
	Database  string `yaml:"database"`
	Username  string `yaml:"username"`
	Password  string `yaml:"password"`
}

// Profile provides the structure for general people profile information
type Profile struct {
	Id           int    `json:"id"`
	FirstName    string `json:"first_name"`
	LastName     string `json:"last_name"`
	EmailAddress string `json:"email_address"`
	City         string `json:"city,omit_empty"`
	State        string `json:"state,omit_empty"`
	Country      string `json:"country,omit_empty"`
	PhoneNumber  string `json:"phone_number,omit_empty"`
}

// JSONResponse
type JSONResponse struct {
	Errors   []string `json:"errors"`
	Entities []Entity `json:"entities"`
}

// Entity
type Entity struct {
	Profiles []Profile `json:"profiles"`
	Pets     []Pet    `json:"pets"`
}

// Pet houses each individual pet
type Pet struct {
	Id        int    `json:"id"`
	Name      string `json:"name"`
	Nickname  string `json:"nickname,omitempty"`
	Type      string `json:"type,omitempty"`
	Breed     string `json:"breed,omitempty"`
	Color     string `json:"color,omitempty"`
	Birthday  string `json:"birthday,omitempty"`
}