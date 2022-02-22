// RepositoriesViewController.swift

import UIKit
import RxSwift
import RxCocoa

class RepositoriesViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!

    private let disposeBag = DisposeBag()
    var viewModel: RepositoriesViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(
            UINib(nibName: "RepositoryTableViewCell", bundle: Bundle.main),
            forCellReuseIdentifier: "RepositoryCell"
        )

        configure()
        setUpBindings()

    }

    private func configure() {
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] _ in self?.searchBar.resignFirstResponder() })
            .disposed(by: disposeBag)

        searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] _ in self?.searchBar.resignFirstResponder() })
            .disposed(by: disposeBag)

        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [weak self] _ in self?.searchBar.setShowsCancelButton(true, animated: true) })
            .disposed(by: disposeBag)

        searchBar.rx.textDidEndEditing
            .subscribe(onNext: { [weak self] _ in self?.searchBar.setShowsCancelButton(false, animated: true) })
            .disposed(by: disposeBag)

        tableView.rx.didScroll
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {
                    return
                }

                if self.searchBar.isFirstResponder {
                    self.searchBar.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
    }

    private func setUpBindings() {
        let query = searchBar.rx.text.orEmpty.asObservable().asObservable()

        let endReached = tableView.rx.didScroll
            .asObservable()
            .map { [weak self] _ in self?.tableView.isNearBottomEdge() ?? false }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in () }

        let rowSelected = tableView.rx.itemSelected.map { $0.row }

        let input = RepositoriesViewModel.Input(
            query: query,
            endReached: endReached,
            rowSelected: rowSelected
        )

        let output = viewModel.transform(input: input)

        output.repositories
            .bind(to: tableView.rx.items(cellIdentifier: "RepositoryCell")) { _, repository, cell in
                guard let cell = cell as? RepositoryTableViewCell else {
                    return
                }

                cell.configure(with: repository)
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

extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}
