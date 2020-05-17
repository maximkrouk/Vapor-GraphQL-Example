import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    try configureCors(app)
    
    try initializeDatabase(app)
    try addMigrations(app)
    
    try routes(app)
}

private func configureCors(_ app: Application) throws {
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    let error = ErrorMiddleware.default(environment: app.environment)
    
    app.middleware = .init()
    app.middleware.use(cors)
    app.middleware.use(error)
}

private func initializeDatabase(_ app: Application) throws {
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
}

private func addMigrations(_ app: Application) throws {
    app.migrations.add(Migrations.UserTokens.Create())
    app.migrations.add(Migrations.Users.Create())
    app.migrations.add(Migrations.Todos.Create())
}
