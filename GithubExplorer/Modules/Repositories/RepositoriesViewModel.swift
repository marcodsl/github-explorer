// RepositoriesViewModel.swift

import RxCocoa
import RxSwift

class RepositoriesViewModel {

    struct Input {
        let query: Observable<String>
        let endReached: Observable<Void>
        let rowSelected: Observable<Int>
    }

    struct Output {
        let repositories: BehaviorRelay<[Repository]>
        let apiRateLimitted: PublishRelay<Void>
    }

    private let disposeBag = DisposeBag()
    private let provider: GithubAPI

    private let apiRateLimitted = PublishRelay<Void>()
    let repositorySelected = PublishRelay<Repository>()

    private var page = 1
    private var query = ""

    init(provider: GithubAPI) {
        self.provider = provider
    }

    func transform(input: Input) -> Output {
        let repositories = BehaviorRelay<[Repository]>(value: [])

        input.query
            .throttle(.milliseconds(700), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest({ [weak self] query -> Observable<[Repository]> in
                guard let self = self else {
                    return .just([])
                }

                self.page = 1
                self.query = query.isEmpty ? "language:Swift" : query

                return self.request()
            })
            .subscribe(onNext: { items in repositories.accept(items) })
            .disposed(by: disposeBag)

        input.endReached
            .flatMapLatest({ [weak self] _ -> Observable<[Repository]> in
                guard let self = self else {
                    return .just([])
                }

                self.page += 1

                return self.request()
            })
            .subscribe(onNext: { items in repositories.accept(repositories.value + items) })
            .disposed(by: disposeBag)

        input.rowSelected
            .map { repositories.value[$0] }
            .bind(to: repositorySelected)
            .disposed(by: disposeBag)

        return Output(
            repositories: repositories,
            apiRateLimitted: apiRateLimitted
        )
    }

    private func request() -> Observable<[Repository]> {
        return provider.searchRepositories(query: query, page: page)
            .map { [weak self] repositorySearch in
                if repositorySearch.message != nil {
                    self?.apiRateLimitted.accept(())
                }

                return repositorySearch.items
            }
            .asObservable()
    }
}
