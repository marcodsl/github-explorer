// GithubAPI.swift

import RxSwift

protocol GithubAPI {
    func searchRepositories(query: String, page: Int) -> Single<RepositorySearch>
    func getPullRequests(repository: Repository, page: Int) -> Single<[PullRequest]>
}
