//
//  Migrations.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Fluent

enum Migrations {}

protocol Migration: Fluent.Migration {}
extension Migration {
    var name: String { String(reflecting: Self.self) }
}
