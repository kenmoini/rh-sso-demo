package main

var readConfig *Config

// BUFFERSIZE is for copying files
const BUFFERSIZE int64 = 4096 // 4096 bits = default page size on OSX

const appName string = "go-pet-id"
const appVersion string = "0.0.1"
const serverUA = appName + "/" + appVersion