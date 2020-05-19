//
//  UsersController.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//
import JWT
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
    
    static func create(_ req: Request) throws -> EventLoopFuture<LoginResponse> {
        let input = try req.content.decode(UserModel.Input.self)
        let model = try UserModel(input)
        let database = req.db
        return model
            .save(on: database)
            .throwingFlatMap { try login(req) }
    }
    
    static func login(_ req: Request) throws -> EventLoopFuture<LoginResponse> {
        let input = try req.content.decode(UserModel.Input.self)
        return eagerLoadedQuery(for: UserModel.self, on: req.db)
            .filter(\.$username, .equal, input.username).first()
            .unwrap(or: Abort(.notFound))
            .guard({ (try? Bcrypt.verify(input.password, created: $0.passwordHash)) == true },
                   else: Abort(.init(statusCode: 400, reasonPhrase: "Incorrect password")))
            .map(\.output)
            .flatMapThrowing {
                LoginResponse(token: try req.jwt.sign(
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

struct LoginResponse: Content {
    var token: String
}

extension EventLoopFuture {
    
    func throwingFlatMap<T>(
        _ callback: @escaping (Value) throws -> EventLoopFuture<T>
    ) -> EventLoopFuture<T> {
        let eventLoop = self.eventLoop
        return flatMap { value in
            do { return try callback(value)
            } catch { return eventLoop.makeFailedFuture(error) }
        }
    }
    
}
