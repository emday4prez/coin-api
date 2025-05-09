import Vapor

func routes(_ app: Application) throws {
    // Register controllers
    try app.register(collection: UserController())
    try app.register(collection: CoinCollectionController())

    // You can also define simple routes directly here
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
}
