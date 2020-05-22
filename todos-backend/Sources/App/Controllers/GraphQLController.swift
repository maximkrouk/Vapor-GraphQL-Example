import GraphQLKit
import Vapor

typealias GraphQLAPIProvider = QLResolverProvider<GraphQLController>
enum GraphQLController: FieldKeyProvider {
    enum FieldKey: String {
        case login
        case register
        case todos
        case newTodo
        case deleteTodo
    }
    
    static func login(_ req: Request, arguments: UserModel.Input) throws -> EventLoopFuture<UserModel.LoginResponse> {
        try GenericController<UserModel>.login(arguments, jwt: req.jwt, on: req.db)
    }
    
    static func register(_ req: Request, arguments: UserModel.Input) throws -> EventLoopFuture<UserModel.LoginResponse> {
        try GenericController<UserModel>.create(arguments, jwt: req.jwt, on: req.db)
    }
    
    static func getTodos(_ req: Request, arguments: NoArguments) throws -> EventLoopFuture<[TodoModel.Output]> {
        try GenericController<TodoModel>.readAll(req)
    }
    
    static func postTodo(_ req: Request, arguments: TodoModel.Input) throws -> EventLoopFuture<TodoModel.Output> {
        try GenericController<TodoModel>.create(arguments, req.auth.require(UserModel.JWTPayload.self), on: req.db)
    }
    
    struct DeleteTodoArguments: Codable {
        var id: UUID
    }
    
    static func deleteTodo(_ req: Request, arguments: DeleteTodoArguments) throws -> EventLoopFuture<HTTPStatus> {
        let payload = try req.auth.require(UserModel.JWTPayload.self)
        return GenericController<TodoModel>.deleteTodo(by: arguments.id, payload, on: req.db)
    }
    
}
