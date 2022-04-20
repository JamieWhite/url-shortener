import Fluent
import Vapor

struct SlackController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let slack = routes.grouped("slack")
        
        let slackProtected = slack.grouped(SlackAuthenticator())
        
        // Create short link
        slackProtected.post("new") { req -> String in
            guard req.auth.has(Slack.self) else {
                throw Abort(.unauthorized)
            }
            
            let slackRequest = try req.content.decode(SlackRequestBody.self)
            let splitText = slackRequest.text.split(separator: " ")
            
            guard splitText.count == 2 else {
                throw Abort(.badRequest)
            }
            
            let shortLink = ShortLink(url: String(splitText[1]), shortName: String(splitText[0]), author: slackRequest.userName, slackUserId: slackRequest.userId)
            
            guard try await ShortLink.query(on: req.db).filter(\.$shortName == shortLink.shortName)
                .first() == nil else {
                return "Short name already exists"
            }
            
            try await shortLink.save(on: req.db)
            
            return "\(shortLink.shortName) successfully created"
        }
        
        slackProtected.post("list") { req -> String in
            guard let hostName = Environment.get("HOSTNAME"), let indexToken = Environment.get("INDEX_TOKEN") else {
                throw Abort(.internalServerError, reason: "Missing HOSTNAME/INDEX_TOKEN")
            }
            
            return "https://\(hostName)/?token=\(indexToken)"
        }
    }
}
