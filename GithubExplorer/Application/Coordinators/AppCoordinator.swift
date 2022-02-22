// AppCoordinator.swift

import UIKit

class AppCoordinator: BaseCoordinator {

    override func start() {
        navigationController.navigationBar.isHidden = true

        let repositoriesCoordinator = RepositoriesCoordinator(navigationController: navigationController)

        start(coordinator: repositoriesCoordinator)
    }

}
