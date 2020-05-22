//
//  Users.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Fluent

extension Migrations {
    enum Users {}
}

extension Migrations.Users {
    struct Create: Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("users")
                .id()
                .field("username", .string, .required)
                .field("password_hash", .string, .required)
                .unique(on: "username")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("users").delete()
        }
    }
}

