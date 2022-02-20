//
//  CustomTextField.swift
//  UILib44
//
//  Created by Valeriy on 20.02.2022.
//

import UIKit

public enum InputTextFieldType {
    case email
    case text
}

public enum InputTextFieldButtonType {
    case none
    case clear
    case custom
}

public protocol InputTextFieldProtocol: UIView {
    var text: String? { get set }
    var isEnabled: Bool { get set }
    var actionDelegate: InputActionDelegate? { get set }
    var focusObserverDelegate: FocusObserverDelegate? { get set }

    func showErrorLabel(_ error: String)
    func requestFocus()
    func releaseFocus()
    func setCustomIcon(icon: UIImage, onButtonClick: @escaping () -> Void)
    func setClearIcon()
    func removeIcon()
}

public protocol FocusObserverDelegate: AnyObject {
    func textFieldGetFocus(sender: InputTextField)
    func textFieldLostFocus(sender: InputTextField)
}

public protocol InputActionDelegate: AnyObject {
    func endEditingAction()
    func returnKeyAction()
}

public final class InputTextField: UIView, InputTextFieldProtocol {

    public var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }

    public var isEnabled: Bool {
        get {
            return textField.isEnabled
        }
        set {
            textField.isEnabled = newValue
        }
    }

    private let placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.textColor = CustomColors.gray.color
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeholderLabel
    }()

    private var textField: UITextField = {
        let textField = UITextField()
        textField.textColor = CustomColors.levelOne.color
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let backgroundViewForText: UIView = {
        let backgroundViewForText = UIView()
        backgroundViewForText.backgroundColor = CustomColors.lightGray.color
        backgroundViewForText.layer.cornerRadius = Metrics.cornerRadius
        backgroundViewForText.clipsToBounds = true
        backgroundViewForText.translatesAutoresizingMaskIntoConstraints = false
        return backgroundViewForText
    }()

    private let errorLabel: UILabel = {
        let errorLabel = UILabel()
        errorLabel.textColor = CustomColors.red.color
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        return errorLabel
    }()

    private let iconButton: UIButton = {
        let iconButton = UIButton(type: .system)
        iconButton.tintColor = CustomColors.gray.color
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        return iconButton
    }()

    private var showPlaceholderConstraint: NSLayoutConstraint!
    private var hidePlaceholderConstraint: NSLayoutConstraint!
    private var showErrorConstraint: NSLayoutConstraint!
    private var hideErrorConstraint: NSLayoutConstraint!
    private var textFieldTrailingWithoutIcon: NSLayoutConstraint!
    private var textFieldTrailingWithIcon: NSLayoutConstraint!

    private var textFieldCurrentPlaceholder: String?
    private var label: String?

    private let inputTextFieldType: InputTextFieldType
    private var onButtonClickAction: () -> Void = {}
    private var buttonType = InputTextFieldButtonType.none
    private var errorCondition = false

    public weak var actionDelegate: InputActionDelegate?
    public weak var focusObserverDelegate: FocusObserverDelegate?

    public init(inputTextFieldType: InputTextFieldType,
                placeholder: String,
                label: String) {
        self.inputTextFieldType = inputTextFieldType
        self.label = label

        super.init(frame: .zero)

        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        setupObjects(placeholder: placeholder)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupObjects(placeholder: String) {
        textField.delegate = self

        switch inputTextFieldType {
        case .email:
            textField.returnKeyType = UIReturnKeyType.go
            textField.keyboardType = .emailAddress
            textField.textContentType = .emailAddress
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .none
        case .text:
            textField.returnKeyType = UIReturnKeyType.go
            textField.keyboardType = .default
            textField.autocapitalizationType = .none
        }

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: CustomColors.gray.color])

        showPlaceholderConstraint = backgroundViewForText.topAnchor.constraint(
            equalTo: placeholderLabel.bottomAnchor, constant: 8)
        hidePlaceholderConstraint = backgroundViewForText.topAnchor.constraint(equalTo: topAnchor)
        showErrorConstraint = bottomAnchor.constraint(equalTo: errorLabel.bottomAnchor)
        hideErrorConstraint = bottomAnchor.constraint(equalTo: backgroundViewForText.bottomAnchor)
        textFieldTrailingWithoutIcon = textField.trailingAnchor.constraint(
            equalTo: backgroundViewForText.trailingAnchor, constant: -16)
        textFieldTrailingWithIcon = textField.trailingAnchor.constraint(
            equalTo: iconButton.leadingAnchor, constant: -8)

        iconButton.addTarget(self, action: #selector(onButtonClicked), for: .touchUpInside)
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addSubview(backgroundViewForText)
        NSLayoutConstraint.activate([
            hidePlaceholderConstraint,
            backgroundViewForText.heightAnchor.constraint(equalToConstant: Metrics.inputGeneralHeight),
            backgroundViewForText.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundViewForText.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        backgroundViewForText.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: backgroundViewForText.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: backgroundViewForText.leadingAnchor, constant: 16)
        ])

        textFieldTrailingWithoutIcon.isActive = true

        addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: backgroundViewForText.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        hideErrorConstraint.isActive = true
    }

    private func showPlaceholderLabel() {
        textFieldCurrentPlaceholder = textField.placeholder
        placeholderLabel.text = label

        if textField.placeholder == placeholderLabel.text {
            textField.placeholder = nil
        }

        UIView.animate(withDuration: Metrics.animationDuration) {
            self.placeholderLabel.alpha = 1
            self.hidePlaceholderConstraint.isActive = false
            self.showPlaceholderConstraint.isActive = true
            self.superview?.layoutIfNeeded()
        }
    }

    private func hidePlaceholderLabel() {
        textField.placeholder = textFieldCurrentPlaceholder

        UIView.animate(withDuration: Metrics.animationDuration) {
            self.placeholderLabel.alpha = 0
            self.showPlaceholderConstraint.isActive = false
            self.hidePlaceholderConstraint.isActive = true
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.placeholderLabel.text = nil
        }
    }

    private func hideErrorLabel() {
        errorCondition = false

        removeGlow(backgroundColor: CustomColors.lightGray.color)
        UIView.animate(withDuration: Metrics.animationDuration) {
            self.errorLabel.alpha = 0
            self.showErrorConstraint.isActive = false
            self.hideErrorConstraint.isActive = true
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.errorLabel.text = nil
        }
    }

    private func showFocus() {
        hideErrorLabel()
        showPlaceholderLabel()
        setGlowOnView(glowColor: CustomColors.blue.color, backgroundColor: CustomColors.levelZero.color)
    }

    @objc private func textFieldDidChange() {
        if buttonType == .clear {
            iconButton.isHidden = textField.text?.isEmpty ?? true
        }
    }

    // MARK: - InputTextFieldProtocol

    public func showErrorLabel(_ error: String) {
        errorCondition = true

        Vibrate.vibrate(style: .heavy)

        errorLabel.text = error
        setGlowOnView(glowColor: CustomColors.red.color, backgroundColor: CustomColors.levelZero.color)
        UIView.animate(withDuration: Metrics.animationDuration) {
            self.errorLabel.alpha = 1
            self.hideErrorConstraint.isActive = false
            self.showErrorConstraint.isActive = true
            self.superview?.layoutIfNeeded()
        }
    }

    public func requestFocus() {
        textField.becomeFirstResponder()
    }

    public func releaseFocus() {
        if !errorCondition {
            removeGlow(backgroundColor: CustomColors.lightGray.color)
        }
        textField.resignFirstResponder()
        focusObserverDelegate?.textFieldLostFocus(sender: self)
    }

    public func setCustomIcon(icon: UIImage, onButtonClick: @escaping () -> Void) {
        iconButton.isHidden = false
        removeIcon()
        buttonType = .custom
        onButtonClickAction = onButtonClick
        insertButton(icon: icon)
    }

    public func setClearIcon() {
        iconButton.isHidden = true
        removeIcon()
        buttonType = .clear
        insertButton(icon: CustomIcons.crossCircled.image)
    }

    public func removeIcon() {
        textFieldTrailingWithIcon.isActive = false
        textFieldTrailingWithoutIcon.isActive = true
        iconButton.removeFromSuperview()
        buttonType = .none
    }

    private func insertButton(icon: UIImage) {
        iconButton.setImage(icon, for: .normal)

        backgroundViewForText.addSubview(iconButton)
        NSLayoutConstraint.activate([
            iconButton.centerYAnchor.constraint(equalTo: backgroundViewForText.centerYAnchor),
            iconButton.trailingAnchor.constraint(equalTo: backgroundViewForText.trailingAnchor, constant: -16),
            iconButton.heightAnchor.constraint(equalToConstant: Metrics.buttonSize),
            iconButton.widthAnchor.constraint(equalToConstant: Metrics.buttonSize)
        ])

        textFieldTrailingWithoutIcon.isActive = false
        textFieldTrailingWithIcon.isActive = true
    }

    // MARK: - Glow

    private func setGlowOnView(glowColor: UIColor, backgroundColor: UIColor? = nil) {
        backgroundViewForText.layer.borderColor = glowColor.cgColor
        backgroundViewForText.layer.borderWidth = 2
        backgroundViewForText.layer.shadowRadius = 24
        backgroundViewForText.layer.shadowOffset = CGSize(width: 0, height: 8)
        backgroundViewForText.layer.shadowOpacity = 0.18
        backgroundViewForText.layer.shadowColor = glowColor.cgColor
        backgroundViewForText.layer.shadowPath = UIBezierPath(rect: backgroundViewForText.bounds).cgPath
        backgroundViewForText.layer.masksToBounds = false

        if let color = backgroundColor {
            backgroundViewForText.backgroundColor = color
        }
    }

    private func removeGlow(backgroundColor: UIColor? = nil) {
        backgroundViewForText.layer.borderColor = nil
        backgroundViewForText.layer.borderWidth = 0
        backgroundViewForText.layer.shadowRadius = 0
        backgroundViewForText.layer.shadowOpacity = 0

        if let color = backgroundColor {
            backgroundViewForText.backgroundColor = color
        }
    }

    // MARK: - Button actions

    @objc private func onButtonClicked() {
        switch buttonType {
        case .none:
            break
        case .clear:
            textField.text = nil
            iconButton.isHidden = true
        case .custom:
            onButtonClickAction()
        }
    }
}

// MARK: - UITextFieldDelegate

extension InputTextField: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        showFocus()
        focusObserverDelegate?.textFieldGetFocus(sender: self)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        actionDelegate?.endEditingAction()
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        actionDelegate?.returnKeyAction()
        return true
    }
}

public extension FocusObserverDelegate {
    func textFieldGetFocus(sender: InputTextField) {}
    func textFieldLostFocus(sender: InputTextField) {}
}

private extension Metrics {
    static let buttonSize: CGFloat = 24
    static let inputGeneralHeight: CGFloat = 48
}
