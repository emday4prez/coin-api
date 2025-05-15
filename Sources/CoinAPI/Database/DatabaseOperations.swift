//
//  DatabaseOperations.swift
//  CoinAPI
//
import PostgresClientKit
import Foundation // Needed for UUID

// --- Data Models (Swift Structs) ---
// They should conform to Codable so Vapor can easily convert them to/from JSON.

struct User: Codable {

    let id: UUID?
    let username: String
    let email: String?
    let createdAt: Date?


}

struct CoinType: Codable {
    let id: UUID? // Optional for creation
    let name: String
    let denomination: String?
    let year: Int?
    // Add other fields as per your 'coin_types' table
}

// Represents a row in the user_coins table
struct UserCoin: Codable {
    let userId: UUID
    let coinTypeId: UUID
    let quantity: Int?
}

// --- Database Operations Functions ---

// Insert a new user
func insertUser(user: User, connection: PostgresClientKit) throws -> User {
    let query = """
    INSERT INTO users (id, username, email)
    VALUES ($1, $2, $3)
    RETURNING id, created_at; -- Return generated ID and timestamp
    """

    let id = UUID() // Generate a client-side UUID for the new user
    let params: [PostgresValueConvertible?] = [
        PostgresValue(uuid: id), // $1
        PostgresValue(string: user.username), // $2
        user.email != nil ? PostgresValue(string: user.email!) : nil // $3 (Handle optional email)
    ]

    do {
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() } // Close the statement when done

        let cursor = try statement.execute(parameterValues: params)
        defer { cursor.close() } // Close the cursor when done

        // Retrieve the returned values (id and created_at)
        guard let row = try cursor.retrieveRow() else {
             throw NSError(domain: "DatabaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve new user ID and timestamp after insert"])
        }

        let returnedId: UUID = try row.decode(PostgresValue.self, at: 0).uuid() // Decode $1 (id)
        let returnedCreatedAt: Date = try row.decode(PostgresValue.self, at: 1).timestamp() // Decode $2 (created_at)

        // Return the user with the generated ID and timestamp
        var insertedUser = user
        insertedUser.id = returnedId
        insertedUser.createdAt = returnedCreatedAt
        return insertedUser

    } catch {
        print("Error inserting user: \(error)")
        throw error // Re-throw
    }
}

// Insert a new coin type
func insertCoinType(coinType: CoinType, connection: PostgresConnection) throws -> CoinType {
    let query = """
    INSERT INTO coin_types (id, name, denomination, year)
    VALUES ($1, $2, $3, $4)
    RETURNING id; -- Return generated ID
    """

    let id = UUID() // Generate a client-side UUID
    let params: [PostgresValueConvertible?] = [
        PostgresValue(uuid: id), // $1
        PostgresValue(string: coinType.name), // $2
        coinType.denomination != nil ? PostgresValue(string: coinType.denomination!) : nil, // $3
        coinType.year != nil ? PostgresValue(int: Int32(coinType.year!)) : nil // $4 (Use Int32 for Integer type)
    ]

    do {
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }

        let cursor = try statement.execute(parameterValues: params)
        defer { cursor.close() }

        guard let row = try cursor.retrieveRow() else {
            throw NSError(domain: "DatabaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve new coin type ID after insert"])
       }

        let returnedId: UUID = try row.decode(PostgresValue.self, at: 0).uuid()

        var insertedCoinType = coinType
        insertedCoinType.id = returnedId
        return insertedCoinType

    } catch {
        print("Error inserting coin type: \(error)")
        throw error
    }
}

// Retrieve a user's coin collection (list of coin_type_ids)
func getUserCollection(userId: UUID, connection: PostgresConnection) throws -> [UUID] {
    let query = """
    SELECT coin_type_id
    FROM user_coins
    WHERE user_id = $1;
    """

    let params: [PostgresValueConvertible?] = [
        PostgresValue(uuid: userId) // $1
    ]

    var coinTypeIds: [UUID] = []

    do {
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }

        let cursor = try statement.execute(parameterValues: params)
        defer { cursor.close() }

        // Iterate through the results
        while let row = try cursor.retrieveRow() {
            let coinTypeId: UUID = try row.decode(PostgresValue.self, at: 0).uuid()
            coinTypeIds.append(coinTypeId)
        }

        return coinTypeIds

    } catch {
        print("Error retrieving user collection for user ID \(userId): \(error)")
        throw error // Re-throw
    }
}
