//
//  UsersController.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//
import Vapor
import Fluent

extension GenericController where Model == UserModel {
    
    @discardableResult
    static func setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        return Builder(builder.grouped(schemaPath))
            .set { $0.post(use: create) }
            .set { $0.post("login", use: login) }
            .build()
    }
    
    static func create(_ req: Request) throws -> EventLoopFuture<Model.LoginResponse> {
        try create(req.content.decode(UserModel.Input.self), jwt: req.jwt, on: req.db)
    }
    
    static func login(_ req: Request) throws -> EventLoopFuture<Model.LoginResponse> {
        try login(req.content.decode(UserModel.Input.self), jwt: req.jwt, on: req.db)
    }
    
    static func create(_ input: UserModel.Input, jwt: Request.JWT, on database: Database) throws -> EventLoopFuture<Model.LoginResponse> {
        try UserModel(input)
            .save(on: database)
            .transform(to: try login(input, jwt: jwt, on: database))
    }
    
    static func login(_ input: UserModel.Input, jwt: Request.JWT, on database: Database) throws -> EventLoopFuture<Model.LoginResponse> {
        UserModel.eagerLoadedQuery(on: database)
            .filter(\.$username, .equal, input.username).first()
            .unwrap(or: Abort(.notFound))
            .guard({ (try? Bcrypt.verify(input.password, created: $0.passwordHash)) == true },
                   else: Abort(.init(statusCode: 400, reasonPhrase: "Incorrect password")))
            .flatMapThrowing {
                Model.LoginResponse(token: try jwt.sign(
                    UserModel.JWTPayload(
                        sub: .init(value: $0.id!.uuidString),
                        username: $0.username,
                        exp: .init(value: Date().addingTimeInterval(3600))
                    )
                )
            )
        }
    }
    
}
