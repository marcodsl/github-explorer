// User.swift

struct User: Decodable {

    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
        case login = "login"
    }

    let avatarUrl: String
    let login: String

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        avatarUrl = try values.decode(String.self, forKey: .avatarUrl)
        login = try values.decode(String.self, forKey: .login)
    }

}
