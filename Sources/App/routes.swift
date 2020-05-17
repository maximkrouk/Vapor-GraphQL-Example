import Fluent
import Vapor

func routes(_ app: Application) throws {
    let protected = app.grouped(UserTokenModel.authenticator())
    GenericController<TodoModel>.setupRoutes(protected)
    GenericController<UserModel>.setupRoutes(protected)
}
