import Fluent
import Vapor

final class TodoModel: APIModel {
    static let schema = "todos"
    
    @ID
    var id: UUID?

    @Field(key: "title")
    var title: String
    
    @Field(key: "content")
    var content: String
    
    @Parent(key: "owner_id")
    var user: UserModel
    
    init() { }

    init(id: UUID? = nil, title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
    }
    
}

extension TodoModel {
    
    struct Input: Content {
        var title: String
        var content: String
    }
    
    convenience init(_ input: Input) throws {
        self.init(
            id: UUID(),
            title: input.title,
            content: input.content
        )
    }
    
}

extension TodoModel {
    
    struct Output: Content {
        var id: UUID?
        var title: String
        var content: String
    }
    
    var output: Output { .init(id: id, title: title, content: content) }
    
    static func eagerLoad(to builder: QueryBuilder<TodoModel>) -> QueryBuilder<TodoModel> {
        builder.with(\.$user)
    }
    
}

extension TodoModel {
    
    struct Update: Content {
        var title: String?
        var content: String?
    }
    
    func update(_ update: Update) throws {
        self.update(\.title, using: update.title)
        self.update(\.content, using: update.content)
    }
    
}


