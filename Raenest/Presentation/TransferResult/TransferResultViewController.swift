import UIKit

final class TransferResultViewController: UIViewController {
    var onPrimaryAction: (() -> Void)?

    private let viewModel: TransferResultViewModel

    init(viewModel: TransferResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .never
        configureHierarchy()
        HapticFeedback.prepare()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.isSuccess {
            HapticFeedback.success()
        } else {
            HapticFeedback.error()
        }
    }

    private func configureHierarchy() {
        let icon = UIImageView(image: UIImage(systemName: viewModel.symbolName))
        icon.tintColor = viewModel.isSuccess ? AppColor.success : AppColor.error
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.isAccessibilityElement = true
        icon.accessibilityLabel = viewModel.isSuccess ? "Transfer succeeded" : "Transfer failed"

        let titleLabel = UILabel()
        titleLabel.text = viewModel.title
        titleLabel.font = AppFont.title()
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityTraits.insert(.header)

        let messageLabel = UILabel()
        messageLabel.text = viewModel.message
        messageLabel.font = AppFont.body()
        messageLabel.textColor = AppColor.textSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.adjustsFontForContentSizeCategory = true

        let referenceLabel = UILabel()
        referenceLabel.text = viewModel.referenceText
        referenceLabel.font = AppFont.caption()
        referenceLabel.textColor = AppColor.textSecondary
        referenceLabel.textAlignment = .center
        referenceLabel.isHidden = viewModel.referenceText == nil
        referenceLabel.adjustsFontForContentSizeCategory = true

        let button = UIButton.primary(title: viewModel.primaryActionTitle)
        button.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "resultPrimaryButton"

        let stack = UIStackView(arrangedSubviews: [icon, titleLabel, messageLabel, referenceLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 72),
            icon.heightAnchor.constraint(equalToConstant: 72),

            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    @objc private func primaryTapped() {
        HapticFeedback.impact(.light)
        onPrimaryAction?()
    }
}
