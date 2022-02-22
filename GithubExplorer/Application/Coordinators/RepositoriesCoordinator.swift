// RepositoriesCoordinator.swift

class RepositoriesCoordinator: BaseCoordinator {

    override func start() {
        let repositoriesViewController = RepositoriesViewController()

        let repositoriesViewModel = RepositoriesViewModel(provider: GithubRestAPI())
        repositoriesViewModel.repositorySelected
            .subscribe(onNext: { [weak self] repository in self?.navigateToPullRequestsOf(repository: repository) })
            .disposed(by: disposeBag)

        repositoriesViewController.viewModel = repositoriesViewModel

        navigationController.viewControllers = [repositoriesViewController]
    }

    private func navigateToPullRequestsOf(repository: Repository) {
        let pullRequestsCoordinator = PullRequestsCoordinator(
            navigationController: navigationController,
            repository: repository
        )

        start(coordinator: pullRequestsCoordinator)
    }
}
