// Repository.swift

struct Repository: Decodable {

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case fullName = "full_name"
        case description = "description"

        case owner = "owner"

        case forksCount = "forks_count"
        case stargazersCount = "stargazers_count"
    }

    let name: String
    let fullName: String
    let description: String?

    let owner: User

    let forksCount: Int
    let stargazersCount: Int

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        name = try values.decode(String.self, forKey: .name)
        fullName = try values.decode(String.self, forKey: .fullName)
        description = try values.decodeIfPresent(String.self, forKey: .description)

        owner = try values.decode(User.self, forKey: .owner)

        forksCount = try values.decode(Int.self, forKey: .forksCount)
        stargazersCount = try values.decode(Int.self, forKey: .stargazersCount)
    }

}
