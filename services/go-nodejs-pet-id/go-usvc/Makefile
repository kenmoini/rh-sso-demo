test:
	go build -v -o dist/pet-id

build:
	go build -v -o dist/pet-id

build-linux-amd64:
	env GOOS=linux GOARCH=amd64 go build -v -o dist/pet-id-linux-amd64

build-darwin-amd64:
	env GOOS=darwin GOARCH=amd64 go build -v -o dist/pet-id-darwin-amd64

run:
	go run