import Fluent

extension Migrations {
    enum Todos {}
}

extension Migrations.Todos {
    struct Create: Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema(TodoModel.schema)
                .id()
                .field("title", .string, .required)
                .field("content", .string, .required)
                .field("owner_id", .uuid, .references(UserModel.schema, .id), .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            return database.schema(TodoModel.schema).delete()
        }
    }
}
