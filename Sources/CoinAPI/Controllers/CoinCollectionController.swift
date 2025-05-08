//
//  CoinCollectionController.swift
//  CoinAPI
//
//  Created by Emerson Day on 5/7/25.
//

import Vapor
import PostgresClientKit
import Foundation // Needed for UUID

struct CoinCollectionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        // Define a route like GET /users/{userId}/coins
        users.get(":userId", "coins", use: getUserCoins)
        // Add routes for adding/removing coins: POST /users/{userId}/coins, DELETE /users/{userId}/coins/{coinId}
    }

    // Handles GET /users/{userId}/coins
    func getUserCoins(req: Request) async throws -> [UUID] {
        // 1. Get the userId from the URL path parameters
        guard let userIdString = req.parameters.get("userId"),
              let userId = UUID(uuidString: userIdString) else {
            throw Abort(.badRequest, reason: "Invalid user ID format")
        }

        // 2. Establish Database Connection (Simplified)
        let dbConfig = DatabaseConfig.loadFromEnvironment()
        let connection: PostgresConnection
        do {
            connection = try createDatabaseConnection(config: dbConfig)
             defer { try? connection.close() } // Ensure connection is closed
        } catch {
             throw Abort(.internalServerError, reason: "Failed to connect to database: \(error.localizedDescription)")
        }

        // 3. Perform the database select operation
        do {
            let coinTypeIds = try getUserCollection(userId: userId, connection: connection)

            // 4. Return the list of coin type IDs
            return coinTypeIds

        } catch {
             throw Abort(.internalServerError, reason: "Failed to retrieve user collection: \(error.localizedDescription)")
        }
    }

    // Add methods for adding/removing user coins
    // func addCoinToCollection(req: Request) async throws -> HTTPStatus { ... }
}
