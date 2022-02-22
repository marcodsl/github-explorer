// PullRequestsCoordinator.swift

import UIKit

class PullRequestsCoordinator: BaseCoordinator {

    private let repository: Repository

    init(navigationController: UINavigationController, repository: Repository) {
        self.repository = repository
        super.init(navigationController: navigationController)
    }

    override func start() {
        let pullRequestsViewController = PullRequestsViewController()

        let pullRequestsViewModel = PullRequestsViewModel(provider: GithubRestAPI(), repository: repository)

        pullRequestsViewModel.pullRequestSelected
            .subscribe(onNext: { [weak self] pullRequest in self?.openPullRequestInBrowser(pullRequest: pullRequest) })
            .disposed(by: disposeBag)

        pullRequestsViewModel.backButtonTapped
            .subscribe(onNext: { [weak self] _ in self?.goBack() })
            .disposed(by: disposeBag)

        pullRequestsViewController.viewModel = pullRequestsViewModel

        navigationController.pushViewController(pullRequestsViewController, animated: true)
    }

    private func openPullRequestInBrowser(pullRequest: PullRequest) {
        let url = URL(string: pullRequest.htmlUrl)!
        UIApplication.shared.open(url)
    }

    private func goBack() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.didFinish(coordinator: self)
    }

}
