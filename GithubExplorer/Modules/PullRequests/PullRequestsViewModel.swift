// PullRequestsViewModel.swift

import RxSwift
import RxRelay

class PullRequestsViewModel {

    struct Input {
        let backButtonTapped: Observable<Void>
        let viewDidLoad: Observable<Void>
        let endReached: Observable<Void>
        let rowSelected: Observable<Int>
    }

    struct Output {
        let pullRequests: BehaviorRelay<[PullRequest]>
        let apiRateLimitted: PublishRelay<Void>
    }

    private let disposeBag = DisposeBag()
    private let provider: GithubAPI
    let repository: Repository

    private let apiRateLimitted = PublishRelay<Void>()
    let pullRequestSelected = PublishRelay<PullRequest>()
    let backButtonTapped = PublishRelay<Void>()

    private var page = 1

    init(provider: GithubAPI, repository: Repository) {
        self.provider = provider
        self.repository = repository
    }

    func transform(input: Input) -> Output {
        let pullRequests = BehaviorRelay<[PullRequest]>(value: [])

        input.backButtonTapped
            .bind(to: backButtonTapped)
            .disposed(by: disposeBag)

        input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<[PullRequest]> in
                guard let self = self else {
                    return .just([])
                }

                return self.request()
            }.subscribe(
                onNext: { items in pullRequests.accept(items) },
                onError: { [weak self] _ in self?.apiRateLimitted.accept(()) }
            )
            .disposed(by: disposeBag)

        input.endReached
            .flatMapLatest { [weak self] _ -> Observable<[PullRequest]> in
                guard let self = self else {
                    return .just([])
                }

                self.page += 1

                return self.request()
            }
            .subscribe(
                onNext: { items in pullRequests.accept(pullRequests.value + items) },
                onError: { [weak self] _ in self?.apiRateLimitted.accept(()) }
            )
            .disposed(by: disposeBag)

        input.rowSelected
            .map { pullRequests.value[$0] }
            .bind(to: pullRequestSelected)
            .disposed(by: disposeBag)

        return Output(
            pullRequests: pullRequests,
            apiRateLimitted: apiRateLimitted
        )
    }

    private func request() -> Observable<[PullRequest]> {
        return provider.getPullRequests(repository: repository, page: page).asObservable()
    }

}
