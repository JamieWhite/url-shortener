import Fluent
import Foundation

struct CreateShortLink: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ShortLink.schema)
            .id()
            .field("url", .string, .required)
            .field("short_name", .string, .required)
            .field("author", .string, .required)
            .field("created_at", .date, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("shortlinks").delete()
    }
}
