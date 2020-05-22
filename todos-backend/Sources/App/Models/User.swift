//
//  User.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Fluent
import Vapor
import JWT
import GraphQLKit

final class UserModel: APIModel, FieldKeyProvider {
    static let schema: String = "users"
    
    enum FieldKey: String {
        case id, username
        case passwordHash = "password_hash"
    }
    
    @ID(custom: fieldKey(.id))
    var id: UUID?
    var uuid: UUID { get { id! } set { id = newValue }}
    
    @Field(key: fieldKey(.username))
    var username: String
    
    @Field(key: fieldKey(.passwordHash))
    var passwordHash: String
    
    @Children(for: \TodoModel.$user)
    var todos: [TodoModel]
    
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
    
    struct LoginResponse: Content, FieldKeyProvider {
        enum FieldKey: String { case token }
        var token: String
    }
    
    struct Output: Content, FieldKeyProvider {
        enum FieldKey: String { case id, username }
        var id: UUID?
        var username: String
    }
    
    var output: Output {
        .init(id: id, username: username)
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

extension UserModel {
    struct JWTPayload: JWT.JWTPayload, Authenticatable {
        var sub: SubjectClaim
        var username: String
        var exp: ExpirationClaim
        
        func verify(using signer: JWTSigner) throws {
            try self.exp.verifyNotExpired()
        }
        
        var userID: UUID! { UUID(uuidString: sub.value) }
    }
}

struct JWTUserModelBearerAuthenticator: JWTAuthenticator {
    typealias User = UserModel
    
    func authenticate(jwt: UserModel.JWTPayload, for request: Request) -> EventLoopFuture<Void> {
        UserModel.find(jwt.userID, on: request.db).map {
            guard $0 != nil else { return }
            request.auth.login(jwt)
        }
    }
}
