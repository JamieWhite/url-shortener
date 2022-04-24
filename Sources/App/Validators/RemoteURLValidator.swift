import Vapor

extension Validator where T == String {
    static var remoteUrl: Validator<T> {
        .init {
            guard
                let url = Foundation.URL(string: $0), (url.host != nil && url.scheme != nil)
            else {
                return ValidatorResults.RemoteURL(isValidURL: false)
            }
            return ValidatorResults.RemoteURL(isValidURL: true)
        }
    }
}

extension ValidatorResults {
    struct RemoteURL {
        let isValidURL: Bool
    }
}

extension ValidatorResults.RemoteURL: ValidatorResult {
    var isFailure: Bool {
        !self.isValidURL
    }
    
    var successDescription: String? {
        "is a valid URL"
    }
    
    var failureDescription: String? {
        "is an invalid URL"
    }
}
