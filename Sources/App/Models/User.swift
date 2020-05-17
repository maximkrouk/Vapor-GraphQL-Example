//
//  User.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Fluent
import Vapor

final class UserModel: APIModel {
    static let schema: String = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Children(for: \TodoModel.$user)
    var todos: [TodoModel]
    
    @Children(for: \UserTokenModel.$user)
    var tokens: [UserTokenModel]
    
    init() {}
    
    init(id: UUID?, username: String, passwordHash: String) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
    }
    
}

extension UserModel {
    
    struct Input: Content {
        var username: String
        var password: String
    }
    
    convenience init(_ input: Input) throws {
        self.init(
            id: UUID(),
            username: input.username,
            passwordHash: try Bcrypt.hash(input.password)
        )
    }
    
}

extension UserModel {
    
    struct Output: Content {
        var id: UUID?
        var username: String
        var token: String?
    }
    
    var output: Output { .init(id: id, username: username, token: tokens.first?.value) }
    
    static func eagerLoad(to builder: QueryBuilder<UserModel>) -> QueryBuilder<UserModel> {
        builder.with(\.$tokens)
    }
    
}

extension UserModel {
    
    struct Update: Content {
        var oldUsername: String
        var newUsername: String
    }
    
    func update(_ update: Update) throws {
        guard update.oldUsername == username else { throw PlainError("Incorrect old username") }
        username = update.newUsername
    }
    
}

extension UserModel: Authenticatable {
    func generateToken() throws -> UserTokenModel {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}
