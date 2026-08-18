import UIKit

@MainActor
final class AppCoordinator {
    private let navigationController: UINavigationController
    private let container: AppDependencyContainer

    init(navigationController: UINavigationController, container: AppDependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        container.prepareSecureStorage()
        let viewController = container.makeAmountBeneficiaryViewController { [weak self] draft in
            self?.showConfirmation(draft: draft)
        }
        navigationController.setViewControllers([viewController], animated: false)
    }

    private func showConfirmation(draft: TransferDraft) {
        let viewController = container.makeConfirmSendViewController(
            draft: draft,
            onSuccess: { [weak self] response in
                self?.showResult(
                    TransferResultViewModel(kind: .success(response), draft: draft)
                )
            },
            onFailure: { [weak self] message in
                self?.showResult(
                    TransferResultViewModel(kind: .failure(message), draft: draft)
                )
            }
        )
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showResult(_ viewModel: TransferResultViewModel) {
        let viewController = container.makeResultViewController(viewModel: viewModel) { [weak self] in
            if viewModel.isSuccess {
                self?.start()
            } else {
                self?.navigationController.popViewController(animated: true)
            }
        }
        navigationController.pushViewController(viewController, animated: true)
    }
}
