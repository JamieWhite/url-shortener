import Vapor

struct SlackRequestBody: Content {
    let token: String
    let text: String
    let response_url: URL
    let user_name: String
}

struct SlackResponse: Content {
    let text: String
}
