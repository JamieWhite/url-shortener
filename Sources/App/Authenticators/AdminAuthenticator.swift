import Vapor

struct Admin: Authenticatable {}

struct AdminAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
       if let adminToken = Environment.get("ADMIN_TOKEN"), bearer.token == adminToken {
           request.auth.login(Admin())
       }
   }
}
