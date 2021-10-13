package main

import (
	_ "github.com/go-sql-driver/mysql"
	"database/sql"
	"log"
)

// createDBConnection should always be immediately followed by `defer db.Close()`
func createDBConnection(username string, password string, host string, port string) (*sql.DB, error) {
	db, err := sql.Open("mysql", username + ":" + password + "@tcp(" + host + ":" + port + ")/")
	return db, err
}

// createDBConnectionWithDatabase should always be immediately followed by `defer db.Close()`
func createDBConnectionWithDatabase(username string, password string, host string, port string, database string) (*sql.DB, error) {
	db, err := sql.Open("mysql", username + ":" + password + "@tcp(" + host + ":" + port + ")/" + database)
	return db, err
}

// DBPreflightChecks just sets up the database if needed
func DBPreflightChecks(config *Config) {
	// Create database if needed
	db, err := createDBConnection(config.Application.SQLConnection.Username, config.Application.SQLConnection.Password, config.Application.SQLConnection.Server, config.Application.SQLConnection.Port)
	check(err)

	res, err := db.Query("CREATE DATABASE IF NOT EXISTS " + config.Application.SQLConnection.Database + ";")
	defer res.Close()
	check(err)
	// Close original db, create new one with targeted
	db.Close()

	db, err = createDBConnectionWithDatabase(config.Application.SQLConnection.Username, config.Application.SQLConnection.Password, config.Application.SQLConnection.Server, config.Application.SQLConnection.Port, config.Application.SQLConnection.Database)
	check(err)
	defer db.Close()
	
	// Check for Tables
	profilesRes, err := db.Query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '"+ config.Application.SQLConnection.Database +"' AND table_name = 'profiles';")
	check(err)
	petsRes, err := db.Query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '"+ config.Application.SQLConnection.Database +"' AND table_name = 'pets';")
	check(err)
	petProfileRes, err := db.Query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '"+ config.Application.SQLConnection.Database +"' AND table_name = 'pet_profile';")
	check(err)
	defer profilesRes.Close()
	defer petsRes.Close()
	defer petProfileRes.Close()
	var profileCount    int
	var petCount        int
	var petProfileCount int
	if profilesRes.Next() {
		err = profilesRes.Scan(&profileCount)
		check(err)
	}
	if petsRes.Next() {
		err = petsRes.Scan(&petCount)
		check(err)
	}
	if petProfileRes.Next() {
		err = petProfileRes.Scan(&petProfileCount)
		check(err)
	}

	// Create Tables
	if profileCount == 0 {
		log.Printf("No profiles table found, creating...\n")
		_, err = db.Query(profilesTable)
		check(err)
	}
	if petCount == 0 {
		log.Printf("No pets table found, creating...\n")
		_, err = db.Query(petsTable)
		check(err)
	}
	if petProfileCount == 0 {
		log.Printf("No pet_profile table found, creating...\n")
		_, err = db.Query(petProfileTable)
		check(err)
	}

	log.Printf("Database preflight finished!\n")
}

const petProfileTable = "CREATE TABLE `pet_profile` (`id` int(9) unsigned NOT NULL AUTO_INCREMENT, `pet_id` int(9) unsigned NOT NULL, `profile_id` int(9) unsigned NOT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;"

const petsTable = "CREATE TABLE `pets` (`id` int(9) unsigned NOT NULL AUTO_INCREMENT, `owner_profile_id` int(9) unsigned NOT NULL, `name` text NOT NULL, `nickname` text DEFAULT NULL, `type` text NOT NULL, `breed` text DEFAULT NULL, `color` int(11) DEFAULT NULL, `birthday` date DEFAULT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;"

const profilesTable = "CREATE TABLE `profiles` (`id` int(9) unsigned NOT NULL AUTO_INCREMENT, `user_id` text DEFAULT NULL, `avatar_url` text DEFAULT NULL, `firstname` text NOT NULL, `lastname` text NOT NULL, `email` text NOT NULL, `city` text DEFAULT NULL, `state` text DEFAULT NULL, `country` text DEFAULT NULL, `phone` text DEFAULT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;"