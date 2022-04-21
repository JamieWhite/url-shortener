import Vapor

struct Admin: Authenticatable {}

struct AdminAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        if bearer.token == Environment.URLS.adminToken {
            request.auth.login(Admin())
        }
    }
}
