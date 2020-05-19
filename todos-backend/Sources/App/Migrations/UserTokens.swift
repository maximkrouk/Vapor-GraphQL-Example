//
//  UserTokens.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Fluent

extension Migrations {
    enum UserTokens {}
}

extension Migrations.UserTokens {
    struct Create: Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("tokens")
                .id()
                .field("user_id", .uuid, .references("users", .id))
                .field("value", .string, .required)
                .unique(on: "value")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("tokens").delete()
        }
    }
}


