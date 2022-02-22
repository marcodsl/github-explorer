// BaseCoordinator.swift

import UIKit
import RxSwift

class BaseCoordinator: Coordinator {
    let disposeBag = DisposeBag()

    var navigationController: UINavigationController

    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        fatalError("start() method must be implemented")
    }

    func start(coordinator: Coordinator) {
        childCoordinators.append(coordinator)

        coordinator.parentCoordinator = self
        coordinator.start()
    }

    func didFinish(coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }
    }
}
