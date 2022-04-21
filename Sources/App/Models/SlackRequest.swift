import Vapor

struct SlackRequestBody: Content {
    let text: String
    let responseURL: URL
    let userName: String
    let userId: String
    let apiAppId: String
    
    enum CodingKeys: String, CodingKey {
        case text
        case responseURL = "response_url"
        case userName = "user_name"
        case userId = "user_id"
        case apiAppId = "api_app_id"
    }
}

struct SlackResponse: Content {
    let text: String
}
