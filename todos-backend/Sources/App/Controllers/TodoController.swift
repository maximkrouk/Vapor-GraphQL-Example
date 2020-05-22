//
//  TodoController.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Vapor
import Fluent

extension GenericController where Model == TodoModel {
    
    @discardableResult
    static func setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        return Builder(builder.grouped(schemaPath))
            .set { $0.get(use: readAll) }
            .set { $0.post(use: create) }
            .set { $0.grouped(idPath) }
            .set { $0.on(.DELETE, use: protected(using: UserModel.JWTPayload.self, handler: _deleteByID)) }
            .build()
    }
    
    static func create(_ req: Request) throws -> EventLoopFuture<TodoModel.Output> {
        try create(
            req.content.decode(TodoModel.Input.self),
            req.auth.require(UserModel.JWTPayload.self),
            on: req.db
        )
    }
    
    static func create(_ input: TodoModel.Input, _ payload: UserModel.JWTPayload, on database: Database) throws -> EventLoopFuture<TodoModel.Output> {
        let model = try TodoModel(input)
        model.$user.id = payload.userID
        
        return model.save(on: database)
            .flatMap { model.load(on: database) }
            .unwrap(or: Abort(.notFound))
    }
    
    static func readAll(_ req: Request) throws -> EventLoopFuture<[TodoModel.Output]> {
        let payload = try req.auth.require(UserModel.JWTPayload.self)
        return Model.eagerLoadedQuery(on: req.db)
            .filter(\.$user.$id, .equal, payload.userID).all()
            .map { $0.map(\.output) }
    }
    
    static func deleteTodo(by id: TodoModel.IDValue, _ payload: UserModel.JWTPayload, on database: Database) -> EventLoopFuture<HTTPStatus> {
        Model.eagerLoadedQuery(on: database)
            .filter(\.$user.$id, .equal, payload.userID)
            .filter(\.$id, .equal, id).first()
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: database) }
            .transform(to: .ok)
    }
    
}

final class SomeClass: Model {
    static var schema: String { "some_classes" }
    
    @ID
    var id: UUID?
    
    @Children(for: \Subclass.$owner)
    var subclasses: [Subclass]
    
    init() {}
}

final class Subclass: Model {
    static var schema: String { "subclasses" }
    
    @ID
    var id: UUID?
    
    @Field(key: "someField")
    var value: Int // Хз, как с нетипизированными данными работать))
    
    @Parent(key: "owner_id")
    var owner: SomeClass
    
    init() {}
}
