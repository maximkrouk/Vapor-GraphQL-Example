import Fluent
import GraphQLKit
import Vapor

func routes(_ app: Application) throws {
    let protected = app.grouped(JWTUserModelBearerAuthenticator())
    GenericController<TodoModel>.setupRoutes(protected)
    GenericController<UserModel>.setupRoutes(protected)
    
    setupGraphQL(app)
}

private func setupGraphQL(_ app: Application) {
    let protected = app.grouped(JWTUserModelBearerAuthenticator())
    protected.graphQL("graphQL", schema: app.makeGraphQLSchema(), use: GraphQLAPIProvider())
}
