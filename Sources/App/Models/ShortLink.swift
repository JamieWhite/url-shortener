import Fluent
import Vapor

final class ShortLink: Model, Content {
    static let schema = "shortlinks"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "url")
    var url: String
    
    @Field(key: "short_name")
    var shortName: String
    
    @Field(key: "author")
    var author: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(url: String, shortName: String, author: String) {
        self.url = url
        self.shortName = shortName
        self.author = author
    }
}
