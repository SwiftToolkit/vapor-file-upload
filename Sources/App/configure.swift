import Vapor
import SotoCore

// configures your application
public func configure(_ app: Application) async throws {
    let awsClient = AWSClient()
    app.services.awsClient.use { _ in awsClient }

    // Set the default maximum body size here, or per request
    app.routes.defaultMaxBodySize = "5mb"

    try routes(app)
}

