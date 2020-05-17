import Fluent
import Vapor

let filesQueue = DispatchQueue(
    label: "files",
    qos: .userInitiated,
    attributes: .concurrent,
    autoreleaseFrequency: .workItem,
    target: .global()
)

extension Data {
    static func fromFile(
        _ fileName: String,
        folder: String = "Public"
    ) throws -> Data {
        let directory = DirectoryConfiguration.detect()
        let fileURL = URL(fileURLWithPath: directory.workingDirectory)
            .appendingPathComponent(folder, isDirectory: true)
            .appendingPathComponent(fileName, isDirectory: false)

        return try Data(contentsOf: fileURL)
    }
}

func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<Response> in
        let promise = req.eventLoop.makePromise(of: Response.self)
        print(app.directory)
        filesQueue.async {
            guard let data = try? Data.fromFile("index.html")
            else { return promise.fail(Abort(.internalServerError)) }
            promise.succeed(Response(body: .init(data: data)))
        }
        
        return promise.futureResult
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    let protected = app.grouped(UserTokenModel.authenticator())
    GenericController<TodoModel>.setupRoutes(protected)
    GenericController<UserModel>.setupRoutes(protected)
    GenericController<UserTokenModel>._setupRoutes(protected)
}
