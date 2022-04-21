import Vapor
import NIOSSL

struct Slack: Authenticatable {}

extension HTTPHeaders.Name {
    static var xSlackSignature = HTTPHeaders.Name("X-Slack-Signature")
    static var xSlackRequestTimestamp = HTTPHeaders.Name("X-Slack-Request-Timestamp")
}

struct SlackAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Request) async throws {
        let secretString = Environment.URLS.slackSigningSecret
        let key = SymmetricKey(data: Data(secretString.utf8))
        
        let timestamp = request.headers[.xSlackRequestTimestamp].first ?? ""
        let requestBody = request.body.string
        let stringToVerify = "v0:\(timestamp):\(requestBody ?? "")"

        let signature = HMAC<SHA256>.authenticationCode(for: Data(stringToVerify.utf8), using: key)
        let hash = Data(signature).map { String(format: "%02hhx", $0) }.joined()
        
        if "v0=\(hash)" == request.headers[.xSlackSignature].first ?? "" {
            request.auth.login(Slack())
        }
    }
}
