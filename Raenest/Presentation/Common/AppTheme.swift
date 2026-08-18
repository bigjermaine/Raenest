import UIKit

enum AppColor {
    static let background = UIColor(red: 0.953, green: 0.965, blue: 0.957, alpha: 1)
    static let surface = UIColor.white
    static let primary = UIColor(red: 0.043, green: 0.420, blue: 0.310, alpha: 1)
    static let primaryMuted = UIColor(red: 0.043, green: 0.420, blue: 0.310, alpha: 0.12)
    static let textPrimary = UIColor(red: 0.071, green: 0.141, blue: 0.110, alpha: 1)
    static let textSecondary = UIColor(red: 0.361, green: 0.435, blue: 0.400, alpha: 1)
    static let separator = UIColor(red: 0.890, green: 0.910, blue: 0.898, alpha: 1)
    static let error = UIColor(red: 0.753, green: 0.224, blue: 0.169, alpha: 1)
    static let success = UIColor(red: 0.106, green: 0.541, blue: 0.353, alpha: 1)
    static let chipUnselected = UIColor(red: 0.925, green: 0.941, blue: 0.929, alpha: 1)
}

enum AppFont {
    static func title() -> UIFont { .systemFont(ofSize: 28, weight: .bold) }
    static func section() -> UIFont { .systemFont(ofSize: 16, weight: .semibold) }
    static func body() -> UIFont { .systemFont(ofSize: 15, weight: .regular) }
    static func caption() -> UIFont { .systemFont(ofSize: 13, weight: .medium) }
    static func amount() -> UIFont { .systemFont(ofSize: 40, weight: .bold) }
    static func button() -> UIFont { .systemFont(ofSize: 17, weight: .semibold) }
}

enum MoneyFormatter {
    static func display(amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount.formattedPlain) \(currency)"
    }
}

extension UIView {
    func pinEdges(to view: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }
}

extension UIButton {
    static func primary(title: String) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseBackgroundColor = AppColor.primary
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = AppFont.button()
            return outgoing
        }

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
