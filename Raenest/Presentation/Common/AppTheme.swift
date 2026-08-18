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
    static func title() -> UIFont {
        scaled(.title1, size: 28, weight: .bold, maximumPointSize: 36)
    }

    static func section() -> UIFont {
        scaled(.headline, size: 16, weight: .semibold, maximumPointSize: 22)
    }

    static func body() -> UIFont {
        scaled(.body, size: 15, weight: .regular, maximumPointSize: 22)
    }

    static func caption() -> UIFont {
        scaled(.caption1, size: 13, weight: .medium, maximumPointSize: 18)
    }

    static func amount() -> UIFont {
        scaled(.largeTitle, size: 40, weight: .bold, maximumPointSize: 48)
    }

    static func button() -> UIFont {
        scaled(.body, size: 17, weight: .semibold, maximumPointSize: 24)
    }

    private static func scaled(
        _ style: UIFont.TextStyle,
        size: CGFloat,
        weight: UIFont.Weight,
        maximumPointSize: CGFloat
    ) -> UIFont {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font, maximumPointSize: maximumPointSize)
    }
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
        button.accessibilityTraits.insert(.button)
        return button
    }
}
