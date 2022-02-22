// RepositorySearch.swift

struct RepositorySearch: Decodable {

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items = "items"

        case message = "message"
    }

    let totalCount: Int
    let items: [Repository]

    let message: String?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        totalCount = try values.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        items = try values.decodeIfPresent([Repository].self, forKey: .items) ?? []

        message = try values.decodeIfPresent(String.self, forKey: .message)
    }

}
