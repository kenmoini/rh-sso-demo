package main

import (
	"github.com/segmentio/kafka-go"
	"context"
)

// CreateKafkaConnection creates a connection to Kafka and returns a Conn type struct
func CreateKafkaConnection(server string, port int, topic string, partition int) (*kafka.Conn, error) {
	conn, err := kafka.DialLeader(context.Background(), "tcp", server + ":" + string(port), topic, partition)
	return conn, err
}