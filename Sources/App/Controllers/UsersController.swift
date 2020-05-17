//
//  UsersController.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Vapor

extension GenericController where Model: UserModel {
    
    @discardableResult
    static func setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        let schemaPath = PathComponent(stringLiteral: Model.schema)
        return Builder(builder.grouped(schemaPath))
            .set { $0.on(.POST, "login", use: login) }
            .set { $0.on(.GET, use: _readAll) }
            .set { $0.on(.POST, use: create) }
            .build()
    }
    
    static func create(_ req: Request) throws -> EventLoopFuture<UserModel.Output> {
        let input = try req.content.decode(UserModel.Input.self)
        let model = try UserModel(input)
        let token = try model.generateToken()
        let database = req.db
        return model
            .save(on: database)
            .flatMap { token.save(on: database) }
            .transform(to: Model.Output(id: model.id, username: model.username, token: token.value))
    }
    
    static func login(_ req: Request) throws -> EventLoopFuture<UserModel.Output> {
        let input = try req.content.decode(UserModel.Input.self)
        return eagerLoadedQuery(for: UserModel.self, on: req.db)
            .filter(\.$username, .equal, input.username).first()
            .unwrap(or: Abort(.notFound))
            .guard({ (try? Bcrypt.verify(input.password, created: $0.passwordHash)) == true },
                   else: Abort(.init(statusCode: 400, reasonPhrase: "Incorrect password")))
            .map(\.output)
    }
    
}
