//
//  DatabaseConfig.swift
//  CoinAPI
//


import PostgresClientKit
import Foundation // Needed for ProcessInfo

// Configuration struct to hold database credentials
struct DatabaseConfig {
    let host: String
    let port: Int
    let database: String
    let user: String
    let password: String? // Optional password

    // Helper to create connection configuration
    var connectionConfiguration: PostgresConnection.Configuration {
        var config = PostgresConnection.Configuration()
        config.host = host
        config.port = port
        config.database = database
        config.user = user
        config.password = password
        // Add any other necessary configurations like ssl, etc.
        return config
    }

    // Example: Loading config from environment variables (Recommended!)
    static func loadFromEnvironment() -> DatabaseConfig {
        // IMPORTANT: Get these values from environment variables
        // DO NOT HARDCODE CREDENTIALS IN YOUR CODE
        let host = ProcessInfo.processInfo.environment["DB_HOST"] ?? "localhost"
        let port = Int(ProcessInfo.processInfo.environment["DB_PORT"] ?? "5432") ?? 5432
        let database = ProcessInfo.processInfo.environment["DB_NAME"] ?? "your_database_name" // Replace with your DB name
        let user = ProcessInfo.processInfo.environment["DB_USER"] ?? "your_user" // Replace with your user
        let password = ProcessInfo.processInfo.environment["DB_PASSWORD"] // Get password from environment

        // Basic validation (you might want more robust checks)
        guard !database.isEmpty, !user.isEmpty else {
            fatalError("Database configuration missing required values (DB_NAME, DB_USER)")
        }

        return DatabaseConfig(host: host, port: port, database: database, user: user, password: password)
    }
}

// Function to establish a database connection
// In a real app, manage this connection carefully (e.g., connection pool)
func createDatabaseConnection(config: DatabaseConfig) throws -> PostgresConnection {
    do {
        let connection = try PostgresConnection(configuration: config.connectionConfiguration)
        print("Database connection established successfully!")
        return connection
    } catch {
        print("Error connecting to database: \(error)")
        throw error // Re-throw the error for the caller to handle
    }
}

// Example Usage (for testing connection)
// let dbConfig = DatabaseConfig.loadFromEnvironment()
// do {
//     let connection = try createDatabaseConnection(config: dbConfig)
//     // Use the connection...
//     try connection.close()
// } catch {
//     print("Failed to use database: \(error)")
// }
