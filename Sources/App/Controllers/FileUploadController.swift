import Vapor

struct FileUploadResponse: Content {
    let url: URL
}

struct SignedUploadRequest: Content {
    let fileName: String
}

struct SignedUploadResponse: Content {
    let url: URL
}
