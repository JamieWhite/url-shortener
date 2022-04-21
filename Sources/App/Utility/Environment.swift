import Vapor

extension Environment {
    struct URLS {
        static var hostname: String {
            Environment.get("HOSTNAME") ?? ""
        }
        
        static var indexToken: String {
            Environment.get("INDEX_TOKEN") ?? ""
        }
        
        static var adminToken: String {
            Environment.get("ADMIN_TOKEN") ?? ""
        }
        
        // MARK: Slack
        
        static var slackSigningSecret: String {
            Environment.get("SLACK_SIGNING_SECRET") ?? ""
        }
        
        static var slackClientId: String {
            Environment.get("SLACK_CLIENT_ID") ?? ""
        }
        
        static var slackAppId: String {
            Environment.get("SLACK_APP_ID") ?? ""
        }
        
        static var command: String {
            Environment.get("COMMAND") ?? ""
        }
    }
}
