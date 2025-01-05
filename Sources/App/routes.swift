import Vapor

func routes(_ app: Application) throws {
    app.get("hello") { _ in "Hello, World!" }
}
