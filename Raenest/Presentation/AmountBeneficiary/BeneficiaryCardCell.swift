import UIKit

final class BeneficiaryCardCell: UITableViewCell {
    static let reuseIdentifier = "BeneficiaryCardCell"

    private let cardView = UIView()
    private let avatarView = UIView()
    private let initialsLabel = UILabel()
    private let nameLabel = UILabel()
    private let detailsLabel = UILabel()
    private let checkImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with beneficiary: Beneficiary, selected: Bool) {
        initialsLabel.text = beneficiary.initials
        nameLabel.text = beneficiary.name
        detailsLabel.text = "\(beneficiary.currency)  ·  \(beneficiary.bankName)  ·  \(beneficiary.maskedAccountNumber)  ·  \(beneficiary.country)"
        checkImageView.isHidden = !selected
        cardView.layer.borderWidth = selected ? 2 : 1
        cardView.layer.borderColor = (selected ? AppColor.primary : AppColor.separator).cgColor
        cardView.backgroundColor = selected ? AppColor.primaryMuted : AppColor.surface
        avatarView.backgroundColor = selected ? AppColor.primary : AppColor.chipUnselected
        initialsLabel.textColor = selected ? .white : AppColor.primary
    }

    private func configure() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = AppColor.surface
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = AppColor.separator.cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        avatarView.layer.cornerRadius = 22
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        initialsLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        initialsLabel.textAlignment = .center
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = AppFont.section()
        nameLabel.textColor = AppColor.textPrimary

        detailsLabel.font = AppFont.caption()
        detailsLabel.textColor = AppColor.textSecondary
        detailsLabel.numberOfLines = 2

        let textStack = UIStackView(arrangedSubviews: [nameLabel, detailsLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkImageView.tintColor = AppColor.primary
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.isHidden = true

        contentView.addSubview(cardView)
        cardView.addSubview(avatarView)
        avatarView.addSubview(initialsLabel)
        cardView.addSubview(textStack)
        cardView.addSubview(checkImageView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            avatarView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 44),
            avatarView.heightAnchor.constraint(equalToConstant: 44),

            initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            checkImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            checkImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkImageView.heightAnchor.constraint(equalToConstant: 24),

            textStack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: checkImageView.leadingAnchor, constant: -12),
            textStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            textStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
}
