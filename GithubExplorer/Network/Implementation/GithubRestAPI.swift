// GithubRestAPI.swift

import Alamofire
import RxSwift

class GithubRestAPI: GithubAPI {

    func searchRepositories(query: String, page: Int = 1) -> Single<RepositorySearch> {
        return request(path: "/search/repositories", parameters: ["q": query, "page": String(page)])
    }

    func getPullRequests(repository: Repository, page: Int = 1) -> Single<[PullRequest]> {
        return request(path: "/repos/\(repository.fullName)/pulls", parameters: ["state": "all", "page": String(page)])
    }

    private func request<T: Decodable>(
        path: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil
    ) -> Single<T> {
        return Single.create { single in
            AF.request(
                "https://api.github.com\(path)",
                method: method,
                parameters: parameters,
                encoding: URLEncoding.default,
                headers: ["Accept": "application/json"]
            ).responseDecodable(of: T.self) { response in
                if let error = response.error {
                    single(.failure(error))
                    return
                }

                if let object = response.value {
                    single(.success(object))
                    return
                }

                single(.failure(RxError.unknown))
            }

            return Disposables.create()
        }.observe(on: MainScheduler.instance)
    }
}
