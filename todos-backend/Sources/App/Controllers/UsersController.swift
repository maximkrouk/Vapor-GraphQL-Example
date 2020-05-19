//
//  UsersController.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//
import Vapor

extension GenericController where Model == UserModel {
    
    @discardableResult
    static func setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        return Builder(builder.grouped(schemaPath))
            .set { $0.post(use: create) }
            .set { $0.post("login", use: login) }
            .build()
    }
    
    static func create(_ req: Request) throws -> EventLoopFuture<Model.LoginResponse> {
        let input = try req.content.decode(UserModel.Input.self)
        return try UserModel(input)
            .save(on: req.db)
            .transform(to: try login(req))
    }
    
    static func login(_ req: Request) throws -> EventLoopFuture<Model.LoginResponse> {
        let input = try req.content.decode(UserModel.Input.self)
        return UserModel.eagerLoadedQuery(on: req.db)
            .filter(\.$username, .equal, input.username).first()
            .unwrap(or: Abort(.notFound))
            .guard({ (try? Bcrypt.verify(input.password, created: $0.passwordHash)) == true },
                   else: Abort(.init(statusCode: 400, reasonPhrase: "Incorrect password")))
            .flatMapThrowing {
                Model.LoginResponse(token: try req.jwt.sign(
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
