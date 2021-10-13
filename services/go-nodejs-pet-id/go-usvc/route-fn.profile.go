package main

import (
	"fmt"
	"net/http"
	"context"
	"time"
	"log"
	"encoding/json"
	"strconv"
	"database/sql"
)

// HandleProfile
func HandleProfile(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		GetProfile(w, r)
	}
	
	if r.Method == "POST" {
		PostProfile(w, r)
	}
}

// QueryDBForProfile via user_id
func QueryDBForProfile(db *sql.DB, user_id string, w http.ResponseWriter, r *http.Request) (Profile, error) {
	profilesRes, err := db.Query("SELECT * FROM profiles WHERE user_id = '"+ user_id +"';")
	check(err)
	if err != nil {
		log.Printf("Error %s when selecting rows from profiles table", err)
	}
	defer profilesRes.Close()
	
	//responseSent := false
	for profilesRes.Next() {
		var profileS Profile
		var eUserID sql.NullString
		var eAvatarURL sql.NullString
		var eFirstName sql.NullString
		var eLastName sql.NullString
		var eEmailAddress sql.NullString
		var eCity sql.NullString
		var eState sql.NullString
		var eCountry sql.NullString
		var ePhoneNumber sql.NullString
		
		// for each row, scan the result into our tag composite object
		err = profilesRes.Scan(&profileS.Id,
			&eUserID,
			&eAvatarURL,
			&eFirstName,
			&eLastName,
			&eEmailAddress,
			&eCity,
			&eState,
			&eCountry,
			&ePhoneNumber,
		)
		if err != nil {
			log.Printf("Error %s when scanning row from profiles table", err)
			DefaultEmptyErrorResponse(w, r)
		}

		profileS.UserID = eUserID.String
		profileS.AvatarURL = eAvatarURL.String
		profileS.FirstName = eFirstName.String
		profileS.LastName = eLastName.String
		profileS.EmailAddress = eEmailAddress.String
		profileS.City = eCity.String
		profileS.State = eState.String
		profileS.Country = eCountry.String
		profileS.PhoneNumber = ePhoneNumber.String

		return profileS, nil
		
	}

	return Profile{}, err
}


// QueryDBForProfileById via table id
func QueryDBForProfileById(db *sql.DB, id int64, w http.ResponseWriter, r *http.Request) (Profile, error) {
	profilesRes, err := db.Query("SELECT * FROM profiles WHERE id = '"+ strconv.FormatInt(id, 10) +"';")
	check(err)
	if err != nil {
		log.Printf("Error %s when selecting rows from profiles table", err)
	}
	defer profilesRes.Close()
	
	//responseSent := false
	for profilesRes.Next() {
		var profileS Profile
		var eUserID sql.NullString
		var eAvatarURL sql.NullString
		var eFirstName sql.NullString
		var eLastName sql.NullString
		var eEmailAddress sql.NullString
		var eCity sql.NullString
		var eState sql.NullString
		var eCountry sql.NullString
		var ePhoneNumber sql.NullString
		
		// for each row, scan the result into our tag composite object
		err = profilesRes.Scan(&profileS.Id,
			&eUserID,
			&eAvatarURL,
			&eFirstName,
			&eLastName,
			&eEmailAddress,
			&eCity,
			&eState,
			&eCountry,
			&ePhoneNumber,
		)
		if err != nil {
			log.Printf("Error %s when scanning row from profiles table", err)
			DefaultEmptyErrorResponse(w, r)
		}

		profileS.UserID = eUserID.String
		profileS.AvatarURL = eAvatarURL.String
		profileS.FirstName = eFirstName.String
		profileS.LastName = eLastName.String
		profileS.EmailAddress = eEmailAddress.String
		profileS.City = eCity.String
		profileS.State = eState.String
		profileS.Country = eCountry.String
		profileS.PhoneNumber = ePhoneNumber.String

		return profileS, nil
		
	}

	return Profile{}, err
}

// GetProfile
func GetProfile(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	if r.Method == "GET" {
		// Get User ID
		user_id := r.URL.Query()["user_id"]
		if len(user_id) > 0 {

			// Query the database for the user profile
			config := readConfig
			db, err := createDBConnectionWithDatabase(config.Application.SQLConnection.Username, config.Application.SQLConnection.Password, config.Application.SQLConnection.Server, config.Application.SQLConnection.Port, config.Application.SQLConnection.Database)
			check(err)
			if err != nil {
				log.Printf("Error %s when connecting", err)
			}
			defer db.Close()

			profileS, err := QueryDBForProfile(db, user_id[0], w, r)
			check(err)
			if err != nil {
				log.Printf("Error %s when querying profile", err)
				DefaultEmptyResponse(w, r)
			}

			// Create return item
			ent := Entity{}
			ent.Profiles = []Profile{profileS}
			resP := &JSONResponse{
				Entities: []Entity{ent},
				Errors:   []string{},
			}
			json, _ := json.Marshal(resP)
			fmt.Fprintf(w, string(json))

		} else {
			DefaultEmptyErrorResponse(w, r)
		}
	}
}

// PostProfile
func PostProfile(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	if r.Method == "POST" {
		var profileS Profile
		profileS.UserID = r.FormValue("user_id")
		profileS.FirstName = r.FormValue("first_name")
		profileS.LastName = r.FormValue("last_name")
		profileS.EmailAddress = r.FormValue("email")
		profileS.AvatarURL = r.FormValue("avatar_url")

		// Make sure all required is there
		if ( (profileS.UserID != "") && (profileS.FirstName != "") && (profileS.LastName != "") && (profileS.EmailAddress != "") && (profileS.UserID != "undefined") && (profileS.FirstName != "undefined") && (profileS.LastName != "undefined") && (profileS.EmailAddress != "undefined") ) {
			// Add to Database
			config := readConfig
			db, err := createDBConnectionWithDatabase(config.Application.SQLConnection.Username, config.Application.SQLConnection.Password, config.Application.SQLConnection.Server, config.Application.SQLConnection.Port, config.Application.SQLConnection.Database)
			check(err)
			defer db.Close()

			query := "INSERT INTO profiles (user_id, firstname, lastname, email, avatar_url) VALUES (?, ?, ?, ?, ?)"
			ctx, cancelfunc := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancelfunc()
			stmt, err := db.PrepareContext(ctx, query)
			if err != nil {
			log.Printf("Error %s when preparing SQL statement", err)
			}
			defer stmt.Close()
			
			res, err := stmt.ExecContext(ctx, profileS.UserID, profileS.FirstName, profileS.LastName, profileS.EmailAddress, profileS.AvatarURL)
			if err != nil {
				log.Printf("Error %s when inserting row into profiles table", err)
			}
			log.Printf("%v", res)
			rows, err := res.RowsAffected()
			if err != nil {
				log.Printf("Error %s when finding rows affected", err)
			}
			lid, err := res.LastInsertId()
			if err != nil {
				log.Printf("Error %s when getting LID", err)
			}
			log.Printf("%d profiles created with LID: " + string(lid), rows)
			log.Printf("Product with ID %d created", lid)

			// Query the USer via ID and return the data
			

			profileN, err := QueryDBForProfileById(db, lid, w, r)
			check(err)
			if err != nil {
				log.Printf("Error %s when querying profile", err)
				DefaultEmptyResponse(w, r)
			}

			// Create return item
			ent := Entity{}
			ent.Profiles = []Profile{profileN}
			resP := &JSONResponse{
				Entities: []Entity{ent},
				Errors:   []string{},
			}
			json, _ := json.Marshal(resP)
			fmt.Fprintf(w, string(json))

		} else {
			DefaultEmptyErrorResponse(w, r)
		}
	}
}