//
//  TodoController.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Vapor

extension GenericController where Model == TodoModel {
    
    @discardableResult
    static func setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        let schemaPath = PathComponent(stringLiteral: Model.schema)
        let idPath = PathComponent(stringLiteral: ":".appending(idKey))
        return Builder(builder.grouped(schemaPath))
            .set { $0.on(.GET, use: readAll) }
            .set { $0.on(.POST, use: create) }
            .set { $0.grouped(idPath) }
            .set { $0.on(.GET, use: _readByID) }
            .set { $0.on(.DELETE, use: _deleteByID) }
            .build()
    }
    
    static func create(_ req: Request) throws -> EventLoopFuture<TodoModel.Output> {
        let payload = try req.auth.require(UserModel.JWTPayload.self)
        let input = try req.content.decode(TodoModel.Input.self)
        let model = try TodoModel(input)
        
        model.$user.id = payload.userID
        return model.save(on: req.db)
            .flatMap { model.load(on: req.db) }
            .unwrap(or: Abort(.notFound))
    }
    
    static func readAll(_ req: Request) throws -> EventLoopFuture<[TodoModel.Output]> {
        let payload = try req.auth.require(UserModel.JWTPayload.self)
        return Model.eagerLoadedQuery(on: req.db)
            .filter(\.$user.$id, .equal, payload.userID).all()
            .map { $0.map(\.output) }
    }
}
