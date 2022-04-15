import Fluent
import Vapor

struct SearchTerm: Content {
    var q: String?
}

func routes(_ app: Application) throws {
    app.get(":name") { req -> Response in
        let name = req.parameters.get("name")!
        let shortLink = try await ShortLink.query(on: req.db).filter(\.$shortName == name)
            .first()
        return req.redirect(to: shortLink?.url ?? "/", type: .permanent)
    }

    app.get() { req async throws -> View in
        let shortLinks: [ShortLink]
        if let searchTerm = try? req.query.decode(SearchTerm.self), let q = searchTerm.q {
            shortLinks = try await ShortLink.query(on: req.db).filter(\.$shortName ~~ q).all()
        } else {
            shortLinks = try await ShortLink.query(on: req.db).all()
        }

        return try await req.view.render("index", ["shortlinks": shortLinks])
    }
    
    // MARK: Protected
    
    let protected = app.grouped(UserAuthenticator())
    
    // Create a new URL if it doesn't exist already
    protected.post() { req -> ShortLink in
        try req.auth.require(Admin.self)
        
        let shortLink = try req.content.decode(ShortLink.self)
        
        guard try await ShortLink.query(on: req.db).filter(\.$shortName == shortLink.shortName)
            .first() == nil else {
            throw Abort(.alreadyReported)
        }
        
        try await shortLink.save(on: req.db)
        return shortLink
    }
    
    protected.delete(":name") { req -> HTTPStatus in
        try req.auth.require(Admin.self)
        
        let name = req.parameters.get("name")!
        guard let shortLink = try await ShortLink.query(on: req.db).filter(\.$shortName == name)
            .first() else {
            throw Abort(.notFound)
        }
        try await shortLink.delete(on: req.db)
        return .ok
    }
}
