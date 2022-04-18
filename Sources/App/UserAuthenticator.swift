import Vapor

struct Admin: Authenticatable {}

struct UserAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
       if let adminToken = Environment.get("ADMIN_TOKEN"), bearer.token == adminToken {
           request.auth.login(Admin())
       }
   }
}

struct Slack: Authenticatable {}

struct SlackAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Request) async throws {
        let slackRequest = try request.content.decode(SlackRequestBody.self)
        if let slackToken = Environment.get("SLACK_VERIFICATION_TOKEN"), slackRequest.token == slackToken {
            request.auth.login(Slack())
        }
    }
}
