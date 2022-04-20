import Vapor
import CommonCrypto

struct Slack: Authenticatable {}

struct SlackAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Request) async throws {
        let secretString = Environment.get("SLACK_SIGNING_SECRET") ?? ""
        let key = SymmetricKey(data: Data(secretString.utf8))
        
        let timestamp = request.headers["X-Slack-Request-Timestamp"].first ?? ""
        let requestBody = request.body.string
        let stringToVerify = "v0:\(timestamp):\(requestBody ?? "")"

        let signature = HMAC<SHA256>.authenticationCode(for: Data(stringToVerify.utf8), using: key)
        let hash = Data(signature).map { String(format: "%02hhx", $0) }.joined()
        
        if "v0=\(hash)" == request.headers["X-Slack-Signature"].first ?? "" {
            request.auth.login(Slack())
        }
    }
}
