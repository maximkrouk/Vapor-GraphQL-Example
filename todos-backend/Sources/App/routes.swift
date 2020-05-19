import Fluent
import Vapor

func routes(_ app: Application) throws {
    let protected = app.grouped(JWTUserModelBearerAuthenticator())
    GenericController<TodoModel>.setupRoutes(protected)
    GenericController<UserModel>.setupRoutes(protected)
}
