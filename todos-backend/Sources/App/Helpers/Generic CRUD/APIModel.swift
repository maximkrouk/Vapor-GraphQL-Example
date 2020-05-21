import Fluent
import Vapor

// MARK: - CRUDModel

protocol CRUDModel: Model {
    associatedtype Input: Content
    associatedtype Output: Content
    associatedtype Update: Content
    
    init(_ input: Input) throws
    var output: Output { get }
    func update(_ update: Update) throws
}

extension CRUDModel {
    /// Used for updating specific values in `update` method
    func update<Value>(_ keyPath: WritableKeyPath<Self, Value>, using optional: Value?) {
        var _self = self
        if let value = optional { _self[keyPath: keyPath] = value }
    }
}

// MARK: - EagerLoadProvidingModel

protocol EagerLoadProvidingModel: Model {
    /// Sets up query to load child properties
    ///
    /// Does not modify query by default, should be implemented to load specific fields
    ///
    /// Implementation example:
    /// ```
    /// static func eagerLoad(to builder: QueryBuilder<Self>) -> QueryBuilder<Self> {
    ///     builder.with(\.$field)
    /// }
    /// ```
    ///
    /// Use conveniecne function for access this method
    /// Usage example:
    /// ```
    /// eagerLoadedQuery(for: SomeAPIModel.self, on: req.db) // QueryBuilder<SomeAPIModel>
    /// ```
    static func eagerLoad(to builder: QueryBuilder<Self>) -> QueryBuilder<Self>
}

extension EagerLoadProvidingModel {
    static func eagerLoad(to builder: QueryBuilder<Self>) -> QueryBuilder<Self> { builder }
}

// MARK: - APIModel

protocol APIModel: CRUDModel, EagerLoadProvidingModel {}

extension APIModel {
    static func eagerLoadedQuery(on database: Database) -> QueryBuilder<Self> {
        _eagerLoadedQuery(for: self, on: database)
    }
    
    /// Loads eager loaded instance from the database
    ///
    /// Should not be reimplemented
    func load(on database: Database) -> EventLoopFuture<Output?> {
        Self.load(id, on: database)
    }
    
    /// Loads eager loaded instance from the database
    ///
    /// Should not be reimplemented
    static func load(_ id: IDValue?, on database: Database) -> EventLoopFuture<Output?> {
        _load(self, id, on: database)
    }
    
}

private func _eagerLoadedQuery<Model: APIModel>(for type: Model.Type, on database: Database) -> QueryBuilder<Model> {
    type.eagerLoad(to: database.query(type))
}

private func _load<Model: APIModel>(_ type: Model.Type, _ id: Model.IDValue?, on database: Database)
-> EventLoopFuture<Model.Output?> {
    guard let id = id else { return database.eventLoop.makeSucceededFuture(nil) }
    return _eagerLoadedQuery(for: type, on: database)
        .filter(\._$id == id).first()
        .map { $0?.output }
}

import GraphQLKit

extension APIModel where Self: FieldKeyProvider {
    static func fieldKey(_ key: Self.FieldKey) -> Fluent.FieldKey { .string(key.rawValue) }
}
