//
//  APIModel.swift
//  App
//
//  Created by Maxim Krouk on 4/6/20.
//

import Fluent
import Vapor

protocol CRUDModel: Model {
    associatedtype Input: Content
    associatedtype Output: Content
    associatedtype Update: Content
    
    init(_ input: Input) throws
    var output: Output { get }
    func update(_ update: Update) throws
}

extension CRUDModel {
    func update<Value>(_ keyPath: WritableKeyPath<Self, Value>, using optional: Value?) {
        var _self = self
        if let value = optional { _self[keyPath: keyPath] = value }
    }
}

protocol APIModel: CRUDModel {
    static func eagerLoad(to builder: QueryBuilder<Self>) -> QueryBuilder<Self>
    static func extract(_ id: IDValue?, on database: Database) -> EventLoopFuture<Output?>
}

extension APIModel {
    static func eagerLoad(to builder: QueryBuilder<Self>) -> QueryBuilder<Self> { builder }
    
    static func extract(_ id: IDValue?, on database: Database) -> EventLoopFuture<Output?> {
        guard let id = id else { return database.eventLoop.makeSucceededFuture(nil) }
        return eagerLoad(to: query(on: database).filter(\._$id == id)).first().map { $0?.output }
    }
    
    func extract(from database: Database) -> EventLoopFuture<Output?> {
        return Self.extract(id, on: database)
    }
}

func eagerLoadedQuery<Model: APIModel>(for type: Model.Type, on database: Database) -> QueryBuilder<Model> {
    type.eagerLoad(to: database.query(type))
}
