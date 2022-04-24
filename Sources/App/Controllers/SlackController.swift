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
                return "Incorrect command format. Should be /\(Environment.URLS.command)add [shortName] [URL]"
            }
            
            let shortLink = ShortLink(url: String(splitText[1]), shortName: String(splitText[0]), author: slackRequest.userName, slackUserId: slackRequest.userId)
            
            guard !shortLink.url.contains(Environment.URLS.hostname) else {
                return "No references to \(Environment.URLS.hostname)"
            }
            
            guard try await ShortLink.query(on: req.db).filter(\.$shortName == shortLink.shortName)
                .first() == nil else {
                return "Short name already exists"
            }
            
            try await shortLink.save(on: req.db)
            
            return "<https://\(Environment.URLS.hostname)/\(shortLink.shortName)|\(shortLink.shortName)> created pointing to <\(shortLink.url)|\(shortLink.url)>"
        }
        
        slackProtected.post("delete") { req -> String in
            guard req.auth.has(Slack.self) else {
                throw Abort(.unauthorized)
            }
            
            let slackRequest = try req.content.decode(SlackRequestBody.self)
            
            guard let shortLink = try await ShortLink.query(on: req.db).filter(\.$shortName == slackRequest.text)
                .first() else {
                return "Short name does not exist"
            }
            
            guard (slackRequest.userId == shortLink.slackUserId) || (Environment.URLS.slackAdmins.contains(slackRequest.userId)) else {
                return "Not authorised. You need to be the original author or a Slack admin"
            }
            
            try await shortLink.delete(on: req.db)
            
            return "\(shortLink.shortName) successfully deleted"
        }
        
        slackProtected.post("list") { req -> String in
            guard req.auth.has(Slack.self) else {
                throw Abort(.unauthorized)
            }
            
            return "https://\(Environment.URLS.hostname)/?token=\(Environment.URLS.indexToken)"
        }
    }
}
