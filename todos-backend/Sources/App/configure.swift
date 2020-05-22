import Fluent
import FluentSQLiteDriver
import Vapor
import JWT

// MARK: - Configuration

// configures your application
public func configure(_ app: Application) throws {
    app.logger.trace("Configuring the application")
    
    try configureCors(app)
    
    try createSecretsIfNeeded(app)
    try configureJWT(app)
    
    try initializeDatabase(app)
    try addMigrations(app)
    try performMigrationsIfInitial(app)
    
    try routes(app)
}

// MARK: CORS

private func configureCors(_ app: Application) throws {
    app.logger.trace("Configuring CORS")
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

// MARK: JWT

private func configureJWT(_ app: Application) throws {
    app.logger.trace("Configuring JWT")
    let privateKeyPath = app.directory.workingDirectory + "jwtRS256.key"
    let publicKeyPath = app.directory.workingDirectory + "jwtRS256.key.pub"
    
    let privateKey = try String(contentsOfFile: privateKeyPath)
    let publicKey = try String(contentsOfFile: publicKeyPath)
    
    let privateSigner = try JWTSigner.rs256(key: .private(pem: privateKey.bytes))
    let publicSigner = try JWTSigner.rs256(key: .public(pem: publicKey.bytes))
     
    app.jwt.signers.use(privateSigner, kid: .private)
    app.jwt.signers.use(publicSigner, kid: .public, isDefault: true)
}

// You should not create secrets this way, i guess 🤔
private func createSecretsIfNeeded(_ app: Application) throws {
    app.logger.trace("Configuring secrets")
    let privateKeyPath = app.directory.workingDirectory + "jwtRS256.key"
    if !FileManager.default.fileExists(atPath: privateKeyPath) {
        app.logger.trace("Copying secret key")
        let privateKeySourcePath = URL(fileURLWithPath: #file).pathComponents
            .dropLast() // drop configure.swift
            .dropLast() // drop App
            .dropLast() // drop Sources
            .joined(separator: "/")
            .appending("/Secrets/jwtRS256.key")
        
        let privateKeySource = try String(contentsOfFile: privateKeySourcePath)
        FileManager.default.createFile(
            atPath: privateKeyPath,
            contents: .init(privateKeySource.bytes),
            attributes: .none
        )
    }
    
    let publicKeyPath = app.directory.workingDirectory + "jwtRS256.key.pub"
    if !FileManager.default.fileExists(atPath: publicKeyPath) {
        app.logger.trace("Generating public key")
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = "openssl rsa -in jwtRS256.key -pubout -outform PEM -out jwtRS256.key.pub"
            .components(separatedBy: .whitespaces)
        
        let pipe = Pipe()
        task.standardInput = pipe
        
        try task.run()
        
        pipe.fileHandleForWriting.write("".data(using: .utf8)!)
        
        task.waitUntilExit()
        task.terminate()
    }
}

// MARK: DB

private func initializeDatabase(_ app: Application) throws {
    app.logger.trace("Initializing database")
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
}

private func addMigrations(_ app: Application) throws {
    app.logger.trace("Adding migrations")
    app.migrations.add(Migrations.Users.Create())
    app.migrations.add(Migrations.Todos.Create())
}

private func performMigrationsIfInitial(_ app: Application) throws {
    guard !FileManager.default.fileExists(atPath: app.directory.workingDirectory + "db.sqlite")
    else { return }
    app.logger.trace("Applying initial migrations")
    try app.autoMigrate().wait()
}

// MARK: - JWT Helper Stuff

private extension String {
    var bytes: [UInt8] { .init(self.utf8) }
}

private extension JWKIdentifier {
    static let `public` = JWKIdentifier(string: "public")
    static let `private` = JWKIdentifier(string: "private")
}
