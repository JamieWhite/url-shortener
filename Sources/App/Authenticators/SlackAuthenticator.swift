import Vapor
import NIOSSL

struct Slack: Authenticatable {}

extension HTTPHeaders.Name {
    static var xSlackSignature = HTTPHeaders.Name("X-Slack-Signature")
    static var xSlackRequestTimestamp = HTTPHeaders.Name("X-Slack-Request-Timestamp")
}

struct SlackAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Request) async throws {
        
        // Check App ID
        let slackRequest = try request.content.decode(SlackRequestBody.self)
        
        guard slackRequest.apiAppId == Environment.URLS.slackAppId else {
            return
        }
        
        // Check timestamp
        let timestamp = request.headers[.xSlackRequestTimestamp].first ?? ""
        guard let timestampInt = TimeInterval(timestamp) else {
            return
        }
        
        let timestampDate = Date(timeIntervalSince1970: timestampInt)

        guard Date().distance(to: timestampDate) < 60 * 5 else {
            return
        }
        
        // Check signature
        let secretString = Environment.URLS.slackSigningSecret
        let key = SymmetricKey(data: Data(secretString.utf8))
        
        let requestBody = request.body.string
        let stringToVerify = "v0:\(timestamp):\(requestBody ?? "")"

        let signature = HMAC<SHA256>.authenticationCode(for: Data(stringToVerify.utf8), using: key)
        let hash = Data(signature).map { String(format: "%02hhx", $0) }.joined()
        
        if "v0=\(hash)" == request.headers[.xSlackSignature].first ?? "" {
            request.auth.login(Slack())
        }
    }
}
