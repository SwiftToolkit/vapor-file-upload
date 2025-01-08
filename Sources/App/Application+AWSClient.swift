import SotoCore
import Vapor

extension Application.Services {
    var awsClient: Application.Service<AWSClient> {
        .init(application: application)
    }
}

extension Request.Services {
    var awsClient: AWSClient {
        request.application.services.awsClient.service
    }
}

struct AWSLifecycleHandler: LifecycleHandler {
    func shutdownAsync(_ application: Application) async {
        do {
            try await application.services.awsClient.service.shutdown()
        } catch {}
    }
}
