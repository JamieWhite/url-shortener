import Vapor

struct Slack: Authenticatable {}

struct SlackAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Request) async throws {
        let slackRequest = try request.content.decode(SlackRequestBody.self)
        if let slackToken = Environment.get("SLACK_VERIFICATION_TOKEN"), slackRequest.token == slackToken {
            request.auth.login(Slack())
        }
    }
}
