//
//  UserController.swift
//  CoinAPI
//
//  Created by Emerson Day on 5/7/25.
//

import Vapor
import PostgresClientKit

struct UserController: RouteCollection {
    // We'll pass the database configuration here, or ideally
    // get a connection pool from the request's application context.
    // For simplicity in this example, we'll load config per request,
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
        let connection: PostgresConnection // Declare here
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
             // You might inspect the error to give more specific status codes
             throw Abort(.internalServerError, reason: "Failed to create user: \(error.localizedDescription)")
        }
    }

    // Add other controller methods like getUser(req: Request) -> User
    // func getUser(req: Request) async throws -> User { ... }
}
