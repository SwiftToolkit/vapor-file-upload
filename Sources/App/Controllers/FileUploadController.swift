import Vapor
import SotoS3

struct FileUploadController: RouteCollection {
    let bucketName: String

    init(bucketName: String) {
        self.bucketName = bucketName
    }

    func boot(routes: RoutesBuilder) throws {
        let fileUploads = routes.grouped("files")
        fileUploads.post("upload", use: upload)
        fileUploads.post("signed-upload", use: createSignedURL)
    }

    @Sendable func upload(req: Request) async throws -> FileUploadResponse {
        let file = try req.content.decode(File.self)
        let key = UUID().uuidString + "." + (file.extension ?? "")
        let putObjectRequest = S3.PutObjectRequest(
            acl: .publicRead,
            body: .init(buffer: file.data),
            bucket: bucketName,
            key: key
        )

        let s3 = S3(client: req.services.awsClient)
        _ = try await s3.putObject(putObjectRequest)
        let url = try url(for: key, region: s3.region.rawValue)
        return FileUploadResponse(url: url)
    }

    @Sendable func createSignedURL(req: Request) async throws -> SignedUploadResponse {
        let request = try req.content.decode(SignedUploadRequest.self)
        let s3 = S3(client: req.services.awsClient)
        let url = try url(for: request.fileName, region: s3.region.rawValue)
        let signedURLRequest = try await s3.signURL(
            url: url,
            httpMethod: .PUT,
            headers: ["x-amz-acl": "public-read"],
            expires: .minutes(10)
        )

        return .init(url: signedURLRequest)
    }

    private func url(for key: String, region: String) throws -> URL {
        let urlString = "https://\(bucketName).s3.\(region).amazonaws.com/\(key)"

        guard let url = URL(string: urlString) else {
            throw Abort(.internalServerError)
        }

        return url
    }
}

struct FileUploadResponse: Content {
    let url: URL
}

struct SignedUploadRequest: Content {
    let fileName: String
}

struct SignedUploadResponse: Content {
    let url: URL
}
