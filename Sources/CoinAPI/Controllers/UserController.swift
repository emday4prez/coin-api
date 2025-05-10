//
//  UserController.swift
//  CoinAPI
//


import Vapor
import PostgresClientKit

struct UserController: RouteCollection {
    //  pass the database configuration here, or ideally
    // get a connection pool from the request's application context.
    //  load config per request,
    // but in a real app, manage connections centrally.

    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: createUser) // POST /users
        // Add other user routes like GET /users/{userId}, PUT /users/{userId}, DELETE /users/{userId}
    }

    // Handles POST /users
    func createUser(req: Request) async throws -> User {
        // 1. Decode the incoming JSON request body into a User struct
        let newUser = try req.content.decode(User.self)

        // 2. Establish Database Connection (Simplified - In real app, use a pool/service)
        let dbConfig = DatabaseConfig.loadFromEnvironment()
        let connection: PostgresConnection
        do {
            connection = try createDatabaseConnection(config: dbConfig)
            defer { try? connection.close() } // Ensure connection is closed
        } catch {
            // If connection fails, re-throw a Vapor Abort error
            throw Abort(.internalServerError, reason: "Failed to connect to database: \(error.localizedDescription)")
        }


        // 3. Perform the database insert operation
        do {
            let createdUser = try insertUser(user: newUser, connection: connection)
            // 4. Return the created user (includes the assigned ID)
            return createdUser
        } catch {
             // If insert fails, re-throw a Vapor Abort error
             // give more specific status codes
             throw Abort(.internalServerError, reason: "Failed to create user: \(error.localizedDescription)")
        }
    }

    // Add other controller methods like getUser(req: Request) -> User
    // func getUser(req: Request) async throws -> User { ... }
}
