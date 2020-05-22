import GraphQLKit
import Vapor

extension Application {

    func makeGraphQLSchema() -> QLSchema<GraphQLAPIProvider, Request> {
        QLSchema<GraphQLAPIProvider, Request>([
            QLType(UserModel.self, fields: [
                QLField(.id, at: \.id),
                QLField(.username, at: \.username)
            ]),
            
            QLType(UserModel.Output.self, name: "UserModelOutput", fields: [
                QLField(.id, at: \.id),
                QLField(.username, at: \.username)
            ]),
            
            QLType(UserModel.LoginResponse.self, name: "LoginResponse") {
                QLField(.token, at: \.token)
            },
            
            QLType(TodoModel.self, fields: [
                QLField(.id, at: \.id),
                QLField(.title, at: \.title),
                QLField(.content, at: \.content)
            ]),
            
            QLType(TodoModel.Output.self, name: "TodoModelOutput", fields: [
                QLField(.id, at: \.id),
                QLField(.title, at: \.title),
                QLField(.content, at: \.content)
            ]),
            
            QLScalar(HTTPResponseStatus.self, serialize: { status in
                .int(Int(status.code))
            }, parse: { map in
                .init(statusCode: map.int ?? 0)
            }),
            
            QLQuery([
                QLField(GraphQLController.self, .todos) { $0.getTodos }
            ]),
            
            QLMutation([
                QLField(GraphQLController.self, .login) { $0.login },
                QLField(GraphQLController.self, .register) { $0.register },
                QLField(GraphQLController.self, .newTodo) { $0.postTodo },
                QLField(GraphQLController.self, .deleteTodo) { $0.deleteTodo }
            ])
        ])
    }

}
