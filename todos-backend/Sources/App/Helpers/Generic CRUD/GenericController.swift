import Vapor
import Fluent

enum GenericController<Model: APIModel>
where Model.IDValue: LosslessStringConvertible {
    
    /// ID parameter key
    static var idKey: String { "id" }
    
    /// ID path component
    static var idPath: PathComponent { .init(stringLiteral: ":\(idKey)") }
    
    /// Schema path component
    static var schemaPath: PathComponent { .init(stringLiteral: Model.schema) }
    
    /// Extracts id parameter from a database
    static func getID(_ req: Request) throws -> Model.IDValue {
        guard let id = req.parameters.get(idKey, as: Model.IDValue.self) else {
            throw Abort(.badRequest)
        }
        return id
    }
    
    /// Creates a new l managed objects in a database
    static func _findByID(_ req: Request) throws -> EventLoopFuture<Model> {
        Model.find(try getID(req), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    /// Creates a new l managed objects in a database
    static func _create(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        let request = try req.content.decode(Model.Input.self)
        let model = try Model(request)
        return model.save(on: req.db)
            .flatMap { model.load(on: req.db) }
            .unwrap(or: Abort(.notFound))
    }
    
    /// Reads all managed objects' output from a database
    static func _readAll(_ req: Request) throws -> EventLoopFuture<Page<Model.Output>> {
        Model.eagerLoadedQuery(on: req.db).paginate(for: req).map { $0.map(\.output) }
    }

    /// Reads specified managed object' output from a database
    static func _readByID(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        Model.load(try getID(req), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    /// Updates specified managed object in a database
    static func _updateByID(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        let content = try req.content.decode(Model.Update.self)
        return try _findByID(req)
            .flatMapThrowing { model -> Model in
                try modification(of: model) { try $0.update(content) }
        }
        .flatMap { $0.update(on: req.db).transform(to: $0) }
        .flatMap { Model.load($0.id, on: req.db) }
        .unwrap(or: Abort(.notFound))
    }
    
    /// Deletes managed object from a database
    static func _deleteByID(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try _findByID(req).flatMap { $0.delete(on: req.db) }.transform(to: .ok)
    }
    
    /// Makes initial routes setup
    ///
    /// Uses default methods (without auth stuff) to setup routes:
    /// ```
    /// ┌––––––––––┬–––––––––––––┐
    /// |   GET    | /schema     |
    /// ├––––––––––┼–––––––––––––┤
    /// |   POST   | /schema     |
    /// ├––––––––––┼–––––––––––––┤
    /// |   GET    | /schema/:id |
    /// ├––––––––––┼–––––––––––––┤
    /// |   PUT    | /schema/:id |
    /// ├––––––––––┼–––––––––––––┤
    /// |  DELETE  | /schema/:id |
    /// └––––––––––┴–––––––––––––┘
    /// ```
    @discardableResult
    static func _setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        return Builder(builder.grouped(schemaPath))
            .set { $0.on(.GET, use: _readAll) }
            .set { $0.on(.POST, use: _create) }
            .set { $0.grouped(idPath) }
            .set { $0.on(.GET, use: _readByID) }
            .set { $0.on(.PUT, use: _updateByID) }
            .set { $0.on(.DELETE, use: _deleteByID) }
            .build()
    }
    
}

// MARK: - Secure routing

extension GenericController {
    
    /// Protects the route
    static func protected<Requirement: Authenticatable, Response>(
        _ req: Request,
        using auth: Requirement.Type,
        handler: @escaping (Request) throws -> Response
    ) throws -> Response { try protected(using: auth, handler: handler)(req) }
    
    
    /// Protects the route
    static func protected<Requirement: Authenticatable, Response>(
        _ req: Request,
        using auth: Requirement.Type,
        handler: @escaping (Request, Requirement) throws -> Response
    ) throws -> Response { try protected(using: auth, handler: handler)(req) }
    
    /// Protects the route
    static func protected<Requirement: Authenticatable, Response>(
        using auth: Requirement.Type,
        handler: @escaping (Request) throws -> Response
    ) -> (Request) throws -> Response {
        protected(using: auth) { request, _ in try handler(request) }
    }
    
    /// Protects the route
    static func protected<Requirement: Authenticatable, Response>(
        using auth: Requirement.Type,
        handler: @escaping (Request, Requirement) throws -> Response
    ) -> (Request) throws -> Response {
        { request in
            return try handler(request, try request.auth.require(auth))
        }
    }
    
}
