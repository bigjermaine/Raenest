import UIKit

final class ConfirmSendViewController: UIViewController {
    private let viewModel: ConfirmSendViewModel
    private let confirmButton = UIButton.primary(title: "Confirm & Send")
    private let bannerLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)

    init(viewModel: ConfirmSendViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Confirm"
        view.backgroundColor = AppColor.background
        navigationItem.largeTitleDisplayMode = .never
        configureHierarchy()
        bindViewModel()
        HapticFeedback.prepare()
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    private func render(_ state: ConfirmSendViewModel.State) {
        let bannerAppeared = state.bannerMessage != nil && bannerLabel.isHidden
        confirmButton.isEnabled = !state.isSending
        confirmButton.alpha = state.isSending ? 0.7 : 1
        confirmButton.accessibilityValue = state.isSending ? "Sending" : nil
        bannerLabel.text = state.bannerMessage
        bannerLabel.isHidden = state.bannerMessage == nil
        if bannerAppeared, let message = state.bannerMessage {
            HapticFeedback.warning()
            UIAccessibility.post(notification: .announcement, argument: message)
        }
        if state.isSending {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }

    private func configureHierarchy() {
        let amountCard = summaryCard(
            title: "Amount",
            value: viewModel.amountText,
            subtitle: viewModel.draft.currency
        )
        let beneficiaryCard = summaryCard(
            title: "Beneficiary",
            value: viewModel.beneficiaryName,
            subtitle: "\(viewModel.beneficiaryDetails)\n\(viewModel.countryText)"
        )

        let notice = UILabel()
        notice.text = "Face ID or Touch ID is required to authorize this transfer."
        notice.font = AppFont.caption()
        notice.textColor = AppColor.textSecondary
        notice.numberOfLines = 0
        notice.adjustsFontForContentSizeCategory = true

        bannerLabel.font = AppFont.caption()
        bannerLabel.textColor = AppColor.error
        bannerLabel.numberOfLines = 0
        bannerLabel.isHidden = true
        bannerLabel.adjustsFontForContentSizeCategory = true
        bannerLabel.accessibilityIdentifier = "confirmBanner"

        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        confirmButton.accessibilityLabel = "Confirm and send"
        confirmButton.accessibilityHint = "Authenticates with Face ID or Touch ID, then sends the transfer."
        confirmButton.accessibilityIdentifier = "confirmSendButton"

        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addSubview(spinner)

        let stack = UIStackView(arrangedSubviews: [amountCard, beneficiaryCard, notice, bannerLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            confirmButton.heightAnchor.constraint(equalToConstant: 56),

            spinner.centerYAnchor.constraint(equalTo: confirmButton.centerYAnchor),
            spinner.trailingAnchor.constraint(equalTo: confirmButton.trailingAnchor, constant: -20)
        ])
    }

    private func summaryCard(title: String, value: String, subtitle: String) -> UIView {
        let card = UIView()
        card.backgroundColor = AppColor.surface
        card.layer.cornerRadius = 20
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = AppFont.caption()
        titleLabel.textColor = AppColor.textSecondary
        titleLabel.adjustsFontForContentSizeCategory = true

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.textColor = AppColor.textPrimary
        valueLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = AppFont.body()
        subtitleLabel.textColor = AppColor.textSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontForContentSizeCategory = true

        card.isAccessibilityElement = true
        card.accessibilityLabel = "\(title), \(value), \(subtitle)"

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        stack.pinEdges(to: card, insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        return card
    }

    @objc private func confirmTapped() {
        HapticFeedback.impact(.medium)
        Task { await viewModel.confirm() }
    }
}
