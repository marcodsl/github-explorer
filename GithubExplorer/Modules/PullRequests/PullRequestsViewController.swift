// PullRequestsViewController.swift

import UIKit
import RxSwift

class PullRequestsViewController: UIViewController {

    @IBOutlet var backButton: UIButton!
    @IBOutlet var repositoryNameLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    private let disposeBag = DisposeBag()
    var viewModel: PullRequestsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(
            UINib(nibName: "PullRequestTableViewCell", bundle: Bundle.main),
            forCellReuseIdentifier: "PullRequestCell"
        )

        repositoryNameLabel.text = viewModel.repository.fullName

        setUpBindings()
    }

    private func setUpBindings() {
        let backButtonTapped = backButton.rx.tap.asObservable().asObservable()

        let viewDidLoad = Observable<Void>.just(())

        let endReached = tableView.rx.didScroll
            .asObservable()
            .map { [weak self] _ in self?.tableView.isNearBottomEdge() ?? false }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in () }

        let rowSelected = tableView.rx.itemSelected.map { $0.row }

        let input = PullRequestsViewModel.Input(
            backButtonTapped: backButtonTapped,
            viewDidLoad: viewDidLoad,
            endReached: endReached,
            rowSelected: rowSelected
        )

        let output = viewModel.transform(input: input)

        output.pullRequests
            .bind(to: tableView.rx.items(cellIdentifier: "PullRequestCell")) { _, pullRequest, cell in
                guard let cell = cell as? PullRequestTableViewCell else {
                    return
                }

                cell.configure(with: pullRequest)
            }
            .disposed(by: disposeBag)

        output.apiRateLimitted
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {
                    return
                }

                let alertController = UIAlertController(
                    title: "Network Error",
                    message: "GitHub API is rate-limiting app's requests",
                    preferredStyle: .alert
                )

                alertController.addAction(UIAlertAction(title: "Ok", style: .default))

                self.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
    }

}
