// PullRequest.swift

import Foundation

struct PullRequest: Decodable {

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case htmlUrl = "html_url"
        case body = "body"

        case user = "user"

        case createdAt = "created_at"
    }

    let title: String
    let htmlUrl: String
    let body: String?

    let user: User

    let createdAt: Date

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        title = try values.decode(String.self, forKey: .title)
        htmlUrl = try values.decode(String.self, forKey: .htmlUrl)
        body = try? values.decode(String.self, forKey: .body)

        user = try values.decode(User.self, forKey: .user)

        let createdAtStr = try values.decode(String.self, forKey: .createdAt)
        let formatter = ISO8601DateFormatter()

        createdAt = formatter.date(from: createdAtStr)!

    }
}
