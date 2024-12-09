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
	// Load environment variables from .env file (if applicable)
	_ = godotenv.Load()

	// Retrieve the secret value
	dbSecret := os.Getenv("DB_SECRET")
	if dbSecret == "" {
		log.Fatal("DB_SECRET environment variable is not set")
	}

	// Parse the JSON string
	var dbConfig map[string]string
	if err := json.Unmarshal([]byte(dbSecret), &dbConfig); err != nil {
		log.Fatalf("Failed to parse DB_SECRET: %v", err)
	}

	// Extract values from the parsed JSON
	user := dbConfig["username"]
	password := dbConfig["password"]
	dbname := dbConfig["db_name"]
	host := dbConfig["db_address"]
	port := dbConfig["port"]

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
