//
//  Button.swift
//  UILib44
//
//  Created by Valeriy on 20.02.2022.
//

import UIKit

public protocol ButtonConfigureProtocol: UIButton {
    var tappedDelegate: ButtonTappedDelegate? { get set }

    func setTitle(_ title: String)
    func setSubtitle(_ subtitle: String)
    func insertIcon(_ icon: UIImage)
    func removeIcon()
}

public enum ButtonStyle: String {
    case textLeftWithoutSubtitle
    case textLeftWithSubtitle
    case textCenterWithoutSubtitle
    case textCenterWithSubtitle
}

public protocol ButtonTappedDelegate: AnyObject {
    func buttonTapped()
}

public final class Button: UIButton, ButtonConfigureProtocol {

    // MARK: - Properties

    private var mainStackViewLeadingConstraint: NSLayoutConstraint!
    private var mainStackViewTrailingConstraint: NSLayoutConstraint!

    private var contentViewLeadingAnchor: NSLayoutConstraint!
    private var contentViewTrailingAnchor: NSLayoutConstraint!
    private var contentViewCenterAnchor: NSLayoutConstraint!
    private var contentViewWidthAnchor: NSLayoutConstraint!

    private let style: ButtonStyle

    public weak var tappedDelegate: ButtonTappedDelegate?

    // MARK: - UI Properties

    private let labelsStackView: UIStackView = {
        let labelsStackView = UIStackView()
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 0
        labelsStackView.alignment = .leading
        labelsStackView.distribution = .fillEqually
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        return labelsStackView
    }()

    private let mainStackView: UIStackView = {
        let mainStackView = UIStackView()
        mainStackView.axis = .horizontal
        mainStackView.spacing = Metrics.sideSpacing
        mainStackView.distribution = .fill
        mainStackView.alignment = .leading
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        return mainStackView
    }()

    private let contentView: UIView = {
        let contentView = UIView()
        contentView.layer.cornerRadius = Metrics.cornerRadius
        contentView.clipsToBounds = true
        contentView.isUserInteractionEnabled = false
        contentView.backgroundColor = CustomColors.blue.color
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    private let buttonTitle: UILabel = {
        let buttonTitle = UILabel()
        buttonTitle.textColor = CustomColors.levelOne.color
        buttonTitle.translatesAutoresizingMaskIntoConstraints = false
        return buttonTitle
    }()

    private let buttonSubtitle: UILabel = {
        let buttonSubtitle = UILabel()
        buttonSubtitle.textColor = CustomColors.levelZero.color
        buttonSubtitle.translatesAutoresizingMaskIntoConstraints = false
        return buttonSubtitle
    }()

    private let buttonIcon: UIImageView = {
        let buttonIcon = UIImageView()
        buttonIcon.contentMode = .scaleAspectFit
        buttonIcon.isHidden = true
        buttonIcon.tintColor = CustomColors.levelZero.color
        buttonIcon.translatesAutoresizingMaskIntoConstraints = false
        return buttonIcon
    }()

    // MARK: - Lifecycle

    public init(style: ButtonStyle) {
        self.style = style

        super.init(frame: .zero)

        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit,
                                                            .touchCancel,
                                                            .touchUpInside,
                                                            .touchUpOutside])

        mainStackViewLeadingConstraint = mainStackView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: Metrics.sideOffset
        )
        mainStackViewTrailingConstraint = mainStackView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -Metrics.sideOffset
        )

        contentViewLeadingAnchor = contentView.leadingAnchor.constraint(equalTo: leadingAnchor)
        contentViewTrailingAnchor = contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
        contentViewCenterAnchor = contentView.centerXAnchor.constraint(equalTo: centerXAnchor)
        contentViewWidthAnchor = contentView.widthAnchor.constraint(equalToConstant: 0)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentViewLeadingAnchor,
            contentViewTrailingAnchor
        ])

        setupLabelsStackView()
        setupMainStackView()
        setupSubtitle()

        heightAnchor.constraint(equalToConstant: Metrics.height).isActive = true
    }

    private func setupLabelsStackView() {
        labelsStackView.addArrangedSubview(buttonTitle)
        labelsStackView.addArrangedSubview(buttonSubtitle)
    }

    private func setupMainStackView() {
        switch style {
        case .textLeftWithoutSubtitle, .textLeftWithSubtitle:
            mainStackView.addArrangedSubview(labelsStackView)
            mainStackView.addArrangedSubview(buttonIcon)

            NSLayoutConstraint.activate([
                buttonIcon.topAnchor.constraint(equalTo: mainStackView.topAnchor),
                buttonIcon.bottomAnchor.constraint(equalTo: mainStackView.bottomAnchor),
                buttonIcon.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
                buttonIcon.widthAnchor.constraint(equalToConstant: Metrics.iconWidth)
            ])

            contentView.addSubview(mainStackView)
            NSLayoutConstraint.activate([
                mainStackViewLeadingConstraint,
                mainStackViewTrailingConstraint,
                mainStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        case .textCenterWithoutSubtitle, .textCenterWithSubtitle:
            mainStackView.addArrangedSubview(buttonIcon)
            mainStackView.addArrangedSubview(labelsStackView)

            NSLayoutConstraint.activate([
                buttonIcon.topAnchor.constraint(equalTo: mainStackView.topAnchor),
                buttonIcon.bottomAnchor.constraint(equalTo: mainStackView.bottomAnchor),
                buttonIcon.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
                buttonIcon.widthAnchor.constraint(equalToConstant: Metrics.iconWidth)
            ])

            contentView.addSubview(mainStackView)
            NSLayoutConstraint.activate([
                mainStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                mainStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        }
    }

    private func setupSubtitle() {
        switch style {
        case .textLeftWithoutSubtitle, .textCenterWithoutSubtitle:
            buttonSubtitle.isHidden = true
        case .textLeftWithSubtitle, .textCenterWithSubtitle:
            buttonSubtitle.isHidden = false
        }
    }

    private func mainStackViewConstrantsCondition(_ condition: Bool) {
        if style == .textLeftWithoutSubtitle || style == .textLeftWithSubtitle {
            mainStackViewLeadingConstraint.isActive = condition
            mainStackViewTrailingConstraint.isActive = condition
        }
    }

    // MARK: - ButtonConfigureProtocol

    public func setTitle(_ title: String) {
        buttonTitle.text = title
    }

    public func setSubtitle(_ subtitle: String) {
        buttonSubtitle.text = subtitle
    }

    public func insertIcon(_ icon: UIImage) {
        buttonIcon.image = icon
        buttonIcon.isHidden = false
    }

    public func removeIcon() {
        buttonIcon.isHidden = true
        buttonIcon.image = nil
    }

    // MARK: - Objc methods

    @objc private func animateUp() {
        contentView.alpha = Metrics.animateUpAlpha
    }

    @objc private func animateDown() {
        contentView.alpha = Metrics.animateDownAlpha
    }

    @objc private func buttonTapped() {
        tappedDelegate?.buttonTapped()
    }
}

private extension Metrics {
    static let height: CGFloat = 52
    static let animateDownAlpha: CGFloat = 0.2
    static let animateUpAlpha: CGFloat = 1
    static let iconWidth: CGFloat = 24
    static let sideOffset: CGFloat = 16
    static let sideSpacing: CGFloat = 12
}
