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
