//
//  GenericController.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Vapor
import Fluent

struct GenericController<Model: APIModel>
where Model.IDValue: LosslessStringConvertible {
    static var idKey: String { "id" }
    
    static func getId(_ req: Request) throws -> Model.IDValue {
        guard let id = req.parameters.get(idKey, as: Model.IDValue.self) else {
            throw Abort(.badRequest)
        }
        return id
    }
    
    static func _findByID(_ req: Request) throws -> EventLoopFuture<Model> {
        Model.find(try getId(req), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    static func _create(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        let request = try req.content.decode(Model.Input.self)
        let model = try Model(request)
        return model.save(on: req.db)
            .flatMap { model.extract(from: req.db) }
            .unwrap(or: Abort(.notFound))
    }
    
    static func _readAll(_ req: Request) throws -> EventLoopFuture<Page<Model.Output>> {
        eagerLoadedQuery(for: Model.self, on: req.db).paginate(for: req).map { $0.map(\.output) }
    }

    static func _readByID(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        Model.extract(try getId(req), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    static func _updateByID(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        let content = try req.content.decode(Model.Update.self)
        return try _findByID(req)
            .flatMapThrowing { model -> Model in
                try modification(of: model) { try $0.update(content) }
        }
        .flatMap { $0.update(on: req.db).transform(to: $0) }
        .flatMap { Model.extract($0.id, on: req.db) }
        .unwrap(or: Abort(.notFound))
    }
    
    static func _deleteByID(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try _findByID(req).flatMap { $0.delete(on: req.db) }.transform(to: .ok)
    }
    
    @discardableResult
    static func _setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        let schemaPath = PathComponent(stringLiteral: Model.schema)
        let idPath = PathComponent(stringLiteral: idKey)
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
