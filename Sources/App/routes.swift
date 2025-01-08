import Vapor

func routes(_ app: Application) throws {
    app.get("hello") { _ in "Hello, World!" }

    // Change the name to a bucket you own
    let bucketName = "<your-bucket-name>"
    let fileUploadController = FileUploadController(
        bucketName: bucketName
    )
    try app.register(collection: fileUploadController)
}
