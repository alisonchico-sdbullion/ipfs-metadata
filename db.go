package main

import (
	"fmt"
	"log"
	"os"

	"github.com/jmoiron/sqlx"
	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

var schema = `
CREATE TABLE IF NOT EXISTS nft_metadata (
    cid TEXT PRIMARY KEY,
    name TEXT,
    image TEXT
)`

type NFTMetadata struct {
	CID   string `db:"cid" json:"cid"`
	Name  string `db:"name" json:"name"`
	Image string `db:"image" json:"image"`
}

func setupDB() (*sqlx.DB, error) {
	// Load environment variables from .env file
	_ = godotenv.Load()

	// Helper function to retrieve environment variables with fallback
	getEnv := func(key, fallback string) string {
		value := os.Getenv(key)
		if value == "" {
			return fallback
		}
		return value
	}

	// Retrieve environment variables, prioritizing those set in the container
	user := getEnv("username", "")
	password := getEnv("password", "")
	dbname := getEnv("db_name", "")
	host := getEnv("db_address", "localhost")
	port := getEnv("port", "5432")

	// Validate required variables
	if user == "" || password == "" || dbname == "" {
		log.Fatal("Required database environment variables are missing: username, password, db_name")
	}

	// Construct the connection string
	connStr := fmt.Sprintf("user=%s password=%s dbname=%s host=%s port=%s sslmode=disable", user, password, dbname, host, port)

	// Connect to the database
	db, err := sqlx.Connect("postgres", connStr)
	if err != nil {
		return nil, err
	}

	// Assume `schema` is predefined elsewhere
	db.MustExec(schema)
	return db, nil
}

func insertMetadata(db *sqlx.DB, cid string, metadata *Metadata) error {
	query := `INSERT INTO nft_metadata (cid, name, image) VALUES ($1, $2, $3) ON CONFLICT (cid) DO NOTHING`
	_, err := db.Exec(query, cid, metadata.Name, metadata.Image)
	return err
}

func getAllMetadata(db *sqlx.DB) ([]NFTMetadata, error) {
	var metadata []NFTMetadata
	err := db.Select(&metadata, "SELECT cid, name, image FROM nft_metadata")
	return metadata, err
}

func getMetadataByCID(db *sqlx.DB, cid string) (*NFTMetadata, error) {
	var metadata NFTMetadata
	err := db.Get(&metadata, "SELECT cid, name, image FROM nft_metadata WHERE cid=$1", cid)
	return &metadata, err
}
