//
//  UserToken.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Vapor
import Fluent

final class UserTokenModel: Model {
   
   	static let schema = "tokens"
   	
   	// MARK: - fields
   
    @ID
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: UserModel
    
    @Field(key: "value")
    var value: String
    
    init() { }
    
    init(id: UUID? = nil,
         value: String,
         userID: UserModel.IDValue)
    {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

extension UserTokenModel: ModelTokenAuthenticatable {
    typealias User = UserModel
    static var valueKey = \UserTokenModel.$value
    static var userKey = \UserTokenModel.$user
    
    var isValid: Bool { true }
}

extension UserTokenModel: APIModel {
    func update(_ update: Update) throws {}
    
    static func eagerLoad(to builder: QueryBuilder<UserTokenModel>) -> QueryBuilder<UserTokenModel> {
        builder.with(\.$user)
    }
    
    static func extract(_ id: UUID?, on database: Database) -> EventLoopFuture<Output?> {
        guard let id = id else { return database.eventLoop.makeSucceededFuture(nil) }
        return eagerLoadedQuery(for: self, on: database)
            .filter(\.$id == id).first()
            .map { $0?.output }
    }
    
    struct Input: Content {}
    
    struct Update: Content {}
    
    struct Output: Content {
        var username: String
        var value: String
    }
    
    convenience init(_ input: Input) throws {
        self.init()
    }
    
    var output: Output { .init(username: user.username, value: value) }
    
}
