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
    
    let protected = app.grouped(UserAuthenticator(), SlackAuthenticator())
    
    // Create a new URL if it doesn't exist already
    protected.post() { req -> String in
        guard req.auth.has(Admin.self) || req.auth.has(Slack.self) else {
            throw Abort(.unauthorized)
        }
        
        let shortLink: ShortLink
        if req.auth.has(Slack.self) {
            let slackRequest = try req.content.decode(SlackRequestBody.self)
            let splitText = slackRequest.text.split(separator: " ")
            
            guard splitText.count == 2 else {
                throw Abort(.badRequest)
            }
            
            shortLink = ShortLink(url: String(splitText[1]), shortName: String(splitText[0]), author: slackRequest.user_name)
        } else {
            shortLink = try req.content.decode(ShortLink.self)
        }
        
        guard try await ShortLink.query(on: req.db).filter(\.$shortName == shortLink.shortName)
            .first() == nil else {
//            throw Abort(.alreadyReported)
            return "Short name already exists"
        }
        
        guard !shortLink.shortName.isEmpty else {
//            throw Abort(.badRequest)
            return "Invalid short name"
        }
        
        guard !shortLink.url.isEmpty, shortLink.url.isValidURL else {
//            throw Abort(.badRequest)
            return "Invalid URL"
        }
        
        try await shortLink.save(on: req.db)
        
        return "\(shortLink.shortName) successfully created"
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
