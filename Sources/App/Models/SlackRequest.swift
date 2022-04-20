import Vapor

struct SlackRequestBody: Content {
    let text: String
    let responseURL: URL
    let userName: String
    
    enum CodingKeys: String, CodingKey {
        case text
        case responseURL = "response_url"
        case userName = "user_name"
    }
}

struct SlackResponse: Content {
    let text: String
}
