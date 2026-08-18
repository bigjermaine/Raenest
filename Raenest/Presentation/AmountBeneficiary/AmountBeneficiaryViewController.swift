import UIKit

final class AmountBeneficiaryViewController: UIViewController {
    private let viewModel: AmountBeneficiaryViewModel

    private let amountField = UITextField()
    private let validationLabel = UILabel()
    private let currencyStack = UIStackView()
    private let searchField = UITextField()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let continueButton = UIButton.primary(title: "Continue")
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var currencyButtons: [UIButton] = []
    private var renderedCurrencies: [String] = []
    private var renderedSelectedCurrency: String?
    private var lastAnnouncedValidation: String?

    init(viewModel: AmountBeneficiaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Send Money"
        view.backgroundColor = AppColor.background
        navigationController?.navigationBar.prefersLargeTitles = true
        configureHierarchy()
        bindViewModel()
        HapticFeedback.prepare()
        viewModel.load()
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    private func render(_ state: AmountBeneficiaryViewModel.State) {
        if amountField.text != state.amountText {
            amountField.text = state.amountText
        }
        validationLabel.text = state.validationMessage
        validationLabel.isHidden = state.validationMessage == nil
        if let message = state.validationMessage, message != lastAnnouncedValidation {
            lastAnnouncedValidation = message
            UIAccessibility.post(notification: .announcement, argument: message)
        } else if state.validationMessage == nil {
            lastAnnouncedValidation = nil
        }
        continueButton.isEnabled = state.isContinueEnabled
        continueButton.alpha = state.isContinueEnabled ? 1 : 0.45
        continueButton.accessibilityHint = state.isContinueEnabled
            ? "Double tap to review this transfer."
            : "Enter a valid amount, choose a currency, and select a beneficiary."
        activityIndicator.isHidden = !state.isLoading
        tableView.isHidden = state.isLoading
        if state.isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }

        if let error = state.loadError {
            validationLabel.text = error
            validationLabel.isHidden = false
        }

        rebuildCurrencyChips(state.allowedCurrencies, selected: state.selectedCurrency)
        tableView.reloadData()
    }

    private func configureHierarchy() {
        let amountCard = makeAmountCard()
        let searchCard = makeSearchField()
        let beneficiariesLabel = UILabel()
        beneficiariesLabel.text = "Beneficiaries"
        beneficiariesLabel.font = AppFont.section()
        beneficiariesLabel.textColor = .black
        beneficiariesLabel.adjustsFontForContentSizeCategory = true
        beneficiariesLabel.accessibilityTraits.insert(.header)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.accessibilityLabel = "Beneficiaries"
        tableView.register(BeneficiaryCardCell.self, forCellReuseIdentifier: BeneficiaryCardCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88

        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        continueButton.isEnabled = false
        continueButton.alpha = 0.45
        continueButton.accessibilityLabel = "Continue to confirmation"
        continueButton.accessibilityHint = "Enter a valid amount, choose a currency, and select a beneficiary."
        continueButton.accessibilityIdentifier = "continueButton"

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = AppColor.primary

        let headerStack = UIStackView(arrangedSubviews: [amountCard, searchCard, beneficiariesLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 16
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerStack)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -12),

            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),

            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func makeAmountCard() -> UIView {
        let card = UIView()
        card.backgroundColor = AppColor.surface
        card.layer.cornerRadius = 20
        card.translatesAutoresizingMaskIntoConstraints = false

        let caption = UILabel()
        caption.text = "You send"
        caption.font = AppFont.caption()
        caption.textColor = AppColor.textSecondary
        caption.adjustsFontForContentSizeCategory = true

        amountField.font = AppFont.amount()
        amountField.textColor = AppColor.textPrimary
        amountField.keyboardType = .decimalPad
        amountField.placeholder = "0.00"
        amountField.adjustsFontForContentSizeCategory = true
        amountField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        amountField.accessibilityIdentifier = "amountField"
        amountField.accessibilityLabel = "Amount to send"
        amountField.accessibilityHint = "Enter an amount between the minimum and maximum."
        amountField.inputAccessoryView = makeKeyboardToolbar()

        validationLabel.font = AppFont.caption()
        validationLabel.textColor = AppColor.error
        validationLabel.numberOfLines = 0
        validationLabel.isHidden = true
        validationLabel.adjustsFontForContentSizeCategory = true
        validationLabel.accessibilityIdentifier = "validationLabel"

        currencyStack.axis = .horizontal
        currencyStack.spacing = 8
        currencyStack.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [caption, amountField, validationLabel, currencyStack])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)
        stack.pinEdges(to: card, insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        return card
    }

    private func makeSearchField() -> UITextField {
        let container = searchField
        container.backgroundColor = AppColor.surface
        container.layer.cornerRadius = 14
        container.layer.borderWidth = 1
        container.layer.borderColor = AppColor.separator.cgColor
        container.font = AppFont.body()
        container.textColor = AppColor.textPrimary
        container.placeholder = "Search name, bank, or account"
        container.adjustsFontForContentSizeCategory = true
        container.accessibilityLabel = "Search beneficiaries"
        container.accessibilityHint = "Filters the list by name, bank, or account number."
        container.clearButtonMode = .whileEditing
        container.leftView = searchIconView()
        container.leftViewMode = .always
        container.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        container.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return container
    }

    private func searchIconView() -> UIView {
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = AppColor.textSecondary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let wrapper = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        wrapper.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 12),
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalToConstant: 18)
        ])
        return wrapper
    }

    private func makeKeyboardToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(dismissKeyboard)
        )
        toolbar.items = [UIBarButtonItem.flexibleSpace(), done]
        return toolbar
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func rebuildCurrencyChips(_ currencies: [String], selected: String) {
        guard currencies != renderedCurrencies || selected != renderedSelectedCurrency else { return }
        renderedCurrencies = currencies
        renderedSelectedCurrency = selected

        currencyStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        currencyButtons = currencies.map { currency in
            var configuration = UIButton.Configuration.filled()
            configuration.title = currency
            configuration.cornerStyle = .capsule
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            let isSelected = currency == selected
            configuration.baseBackgroundColor = isSelected ? AppColor.primary : AppColor.chipUnselected
            configuration.baseForegroundColor = isSelected ? .white : AppColor.textPrimary

            let button = UIButton(configuration: configuration)
            button.tag = currencies.firstIndex(of: currency) ?? 0
            button.accessibilityLabel = "\(currency) currency"
            button.accessibilityTraits = isSelected ? [.button, .selected] : [.button]
            button.accessibilityHint = "Shows beneficiaries who receive \(currency)."
            button.addTarget(self, action: #selector(currencyTapped(_:)), for: .touchUpInside)
            return button
        }
        currencyButtons.forEach { currencyStack.addArrangedSubview($0) }
    }

    @objc private func amountChanged() {
        viewModel.updateAmount(amountField.text ?? "")
    }

    @objc private func searchChanged() {
        viewModel.updateSearch(searchField.text ?? "")
    }

    @objc private func currencyTapped(_ sender: UIButton) {
        let currencies = viewModel.state.allowedCurrencies
        guard currencies.indices.contains(sender.tag) else { return }
        HapticFeedback.selection()
        viewModel.selectCurrency(currencies[sender.tag])
    }

    @objc private func continueTapped() {
        view.endEditing(true)
        HapticFeedback.impact(.medium)
        viewModel.continueTapped()
    }
}

extension AmountBeneficiaryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.state.filteredBeneficiaries.count
        if count == 0, !viewModel.state.isLoading, viewModel.state.loadError == nil {
            tableView.backgroundView = emptyStateView()
        } else {
            tableView.backgroundView = nil
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BeneficiaryCardCell.reuseIdentifier,
            for: indexPath
        ) as? BeneficiaryCardCell else {
            return UITableViewCell()
        }

        let beneficiary = viewModel.state.filteredBeneficiaries[indexPath.row]
        cell.configure(
            with: beneficiary,
            selected: beneficiary.id == viewModel.state.selectedBeneficiaryID
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beneficiary = viewModel.state.filteredBeneficiaries[indexPath.row]
        viewModel.selectBeneficiary(beneficiary)
        HapticFeedback.impact(.light)
    }

    private func emptyStateView() -> UIView {
        let label = UILabel()
        let currency = viewModel.state.selectedCurrency
        let searching = !viewModel.state.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        label.text = searching
            ? "No \(currency) beneficiaries match your search."
            : "No beneficiaries receive \(currency)."
        label.font = AppFont.body()
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        return label
    }
}
