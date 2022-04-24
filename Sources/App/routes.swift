import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    app.get(":name") { req -> Response in
        let name = req.parameters.get("name")!
        let shortLink = try await ShortLink.query(on: req.db).filter(\.$shortName == name)
            .first()
        return req.redirect(to: shortLink?.url ?? "/", type: .permanent)
    }
    
    struct IndexContext: Encodable {
        let shortLinks: [ShortLink]
        let slackId: String
    }

    app.get() { req async throws -> View in
        guard let token: String = req.query["token"], token == Environment.URLS.indexToken else {
            return try await req.view.render("denied", ["command": Environment.URLS.command])
        }
        
        var query = ShortLink.query(on: req.db)
        
        if let q: String = req.query["q"] {
            query = query.filter(\.$shortName ~~ q)
        }
        
        let shortLinks = try await query.sort(\.$shortName).all()

        return try await req.view.render("index", IndexContext(shortLinks: shortLinks,
                                                               slackId: Environment.URLS.slackClientId))
    }
    
    // MARK: Protected
    
    let adminProtected = app.grouped(AdminAuthenticator())
    
    // Create short link
    adminProtected.post() { req -> ShortLink in
        guard req.auth.has(Admin.self) else {
            throw Abort(.unauthorized)
        }
        
        try ShortLink.validate(content: req)
        let shortLink = try req.content.decode(ShortLink.self)
        
        guard try await ShortLink.query(on: req.db).filter(\.$shortName == shortLink.shortName)
            .first() == nil else {
            throw Abort(.alreadyReported)
        }
        
        try await shortLink.save(on: req.db)
        
        return shortLink
    }
    
    // Delete short link
    adminProtected.delete(":name") { req -> HTTPStatus in
        try req.auth.require(Admin.self)
        
        guard let name = req.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        
        guard let shortLink = try await ShortLink.query(on: req.db).filter(\.$shortName == name)
            .first() else {
            throw Abort(.notFound)
        }
        try await shortLink.delete(on: req.db)
        return .ok
    }
    
    try app.register(collection: SlackController())
}
