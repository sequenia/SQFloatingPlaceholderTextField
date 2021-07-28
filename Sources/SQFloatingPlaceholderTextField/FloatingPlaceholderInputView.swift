//
//  FloatingPlaceholderInputView.swift
//  SQFloatingPlaceholderTextField
//
//  Created by Olga Lidman on 05.10.2020.
//

import UIKit

// MARK: - Constants
fileprivate struct Constants {
    
    static let kClearButtonWidth: CGFloat = 30
}

// MARK: - Input Data Delegate
@objc public protocol SQInputDataDelegate: AnyObject {

    @objc optional func inputViewShouldBeginEditing(_ textFieldView: FloatingPlaceholderInputView?) -> Bool
    @objc optional func inputViewDidBeginEditing(_ textFieldView: FloatingPlaceholderInputView?, validate: Bool, error: String?)
    @objc optional func inputViewDidChange(_ textFieldView: FloatingPlaceholderInputView?, validate: Bool, error: String?)
    @objc optional func inputViewDidEndEditing(_ textFieldView: FloatingPlaceholderInputView?, validate: Bool, error: String?)
    @objc optional func inputViewDoneButtonClicked()
}

// MARK: - FloatingPlaceholderInputView class
@IBDesignable open class FloatingPlaceholderInputView: UIView {
  
    
// MARK: - Outlets
    @IBOutlet open var contentView: UIView!
    @IBOutlet open weak var sqTextField: SQTextfield!
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    
    @IBOutlet private weak var buttonWidth: NSLayoutConstraint!
    
// MARK: - Text
    open var text: String? {
        set { self.sqTextField.text = newValue }
        get { return self.sqTextField.text }
    }

    open var clearText: String? {
        get { self.formatter?.onlyString }
    }
    
// MARK: - UI Properties / Colors
    @IBInspectable
    open var inputTintColor: UIColor {
        set { self.sqTextField.tintColor = newValue }
        get { return self.sqTextField.tintColor }
    }
    
    @IBInspectable
    open var textColor: UIColor {
        set { self.sqTextField.textColor = newValue }
        get { return self.sqTextField.textColor ?? .black }
    }
    
    @IBInspectable
    open var placeholderColor: UIColor {
        set { self.placeholderLabel.textColor = newValue }
        get { return self.placeholderLabel.textColor ?? .gray }
    }
    
    @IBInspectable
    open var separatorColor: UIColor {
        set { self.separatorView.backgroundColor = newValue }
        get { return self.separatorView.backgroundColor ?? .gray }
    }
    
    @IBInspectable
    open var keyboardToolTitle: String?
    
    @IBInspectable
    open var keyboardToolTitleColor: UIColor?
    
// MARK: - Clear Button
    @IBInspectable
    open var allowClearButton: Bool {
        set {
            if newValue {
                self.buttonWidth.constant = Constants.kClearButtonWidth
            } else {
                self.buttonWidth.constant = .zero
            }
            self.clearButton.isEnabled = newValue
        }
        get { return self.clearButton.isEnabled }
    }
    
    @IBInspectable
    open var clearButtonImage: UIImage? {
        set { self.clearButton.setImage(newValue, for: .normal) }
        get { return self.clearButton.imageView?.image }
    }
        
// MARK: - Fonts
    open var textFont: UIFont {
        set { self.sqTextField.font = newValue
              self.placeholderLabel.font = newValue
        }
        get { return self.sqTextField.font ?? UIFont.systemFont(ofSize: 16) }
    }
    
    open var placeholderFont: UIFont {
        set { self.placeholderLabel.font = newValue }
        get { return self.placeholderLabel.font }
    }
    
// MARK: - Data
    var delegate: SQInputDataDelegate?
    var type: SQTextFieldType?
    var validator: SQTextFieldValidator?
    var formatter: SQTextFieldFormatter?
    
// MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.construct()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.construct()
    }
    
    private func construct() {
        Bundle.module.loadNibNamed("\(self.classForCoder)", owner: self, options: nil)
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
// MARK: - Life Cycle
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.clearButton.isHidden = true
        self.placeholderLabel.isHidden = true
        self.sqTextField.delegate = self
        self.sqTextField.addTarget(self, action: #selector(sqTextFieldDidChange), for: .editingChanged)
    }
    
// MARK: - Prepare For Reuse
    open func prepareForReuse() {
        self.clearTextField(resign: false)
    }
    
// MARK: - Configure
    open func configure(type: SQTextFieldType,
                        delegate: SQInputDataDelegate?,
                        value: String? = nil,
                        placeholder: String,
                        validator: SQTextFieldValidator?,
                        formatter: SQTextFieldFormatter?) {
        self.delegate = delegate
        self.formatter = formatter != nil ? formatter : SQTextFieldBaseFormatter()
        self.validator = validator != nil ? validator : SQTextFieldBaseValidator(required: false)
        self.setType(type)
        self.setPlaceholder(placeholder)
        self.setTextFieldText(value, appearPlaceholder: false)
    }
    
// MARK: - Set Placeholder
    private func setPlaceholder(_ placeholder: String) {
        self.placeholderLabel.text = placeholder
        self.sqTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.font: self.textFont, .foregroundColor: self.placeholderColor])
    }
    
// MARK: - Set Type
    private func setType(_ type: SQTextFieldType) {
        self.type = type
        
        switch type {
        case .cardNumber, .phoneNumber, .numbers:
            self.addDoneButtonOnKeyboard()
        case .email:
            self.sqTextField.languageCode = LanguageCode.en
        case .password:
            self.sqTextField.isSecureTextEntry = true
        default:
            break
        }
        
        self.sqTextField.keyboardType = type.keyboardType
        self.sqTextField.autocapitalizationType = type.capitalization
    }
    
// MARK: - Set Text
    private func setTextFieldText(_ text: String?, appearPlaceholder: Bool) {
        guard let fieldText = text, fieldText != "" else {
            self.clearButton.isHidden = true
            return }
        self.text = fieldText
        self.clearButton.isHidden = false
        self.appearPlaceholder(animate: appearPlaceholder)
    }
    
// MARK: - Actions
    @IBAction func onClearButtonClicked(_ sender: UIButton) {
        self.clearTextField(resign: true)
        self.textFieldDidEndEditing(self.sqTextField)
    }
    
    @objc func sqTextFieldDidChange() {
        
        if (self.clearText?.count ?? 0) + (self.formatter?.prefix?.count ?? 0) != 0 {
            if self.placeholderLabel.isHidden == true {
                self.appearPlaceholder(animate: true)
            }
        }
        
        if (self.clearText?.isEmpty ?? false)  {
            self.clearTextField(resign: false)
        }

        if self.clearText != "" {
            self.clearButton.isHidden = false
        } else {
            self.clearButton.isHidden = true
        }
        
        self.validateOnChangeText()
    }
    
    private func clearTextField(resign: Bool) {
        self.text?.removeAll()
        self.formatter?.onlyString?.removeAll()
        self.placeholderLabel.isHidden = true
        self.clearButton.isHidden = true
        if resign {
            self.sqTextField.resignFirstResponder()
        }
    }
    
// MARK: - Placeholder Appearance
    private func appearPlaceholder(animate: Bool) {
        if !animate {
            self.placeholderLabel.isHidden = false
            return
        }
        let rect = self.placeholderLabel.frame
        var tempRect = self.placeholderLabel.frame
        tempRect.origin.y = self.placeholderLabel.frame.origin.y + self.placeholderLabel.bounds.size.height
        self.placeholderLabel.frame = tempRect
        self.placeholderLabel.alpha = .zero
        self.placeholderLabel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.placeholderLabel.alpha = 1
            self.placeholderLabel.frame = rect
        }
    }
    
}

// MARK: - TextField Delegate
extension FloatingPlaceholderInputView: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self.delegate?.inputViewShouldBeginEditing?(self) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.validateOnBeginEditing()
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let textReplace = nsString?.replacingCharacters(in: range, with: string)
        self.text = self.formatter?.check(textReplace ?? "") ?? textReplace
        self.sqTextFieldDidChange()
        return false
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if self.clearText?.isEmpty ?? false  {
            self.clearTextField(resign: true)
        }
        self.validateOnEndEditing()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.delegate?.inputViewDoneButtonClicked?()
        return true
    }

}

//  MARK:- Validation
extension FloatingPlaceholderInputView {
    
    func validateOnBeginEditing() {
        switch self.validator?.check(self.text ?? "") {
        case .success:
            self.delegate?.inputViewDidBeginEditing?(self, validate: true, error: nil)
            break
        case let .failure(info)?:
            self.delegate?.inputViewDidBeginEditing?(self, validate: false, error: info)
            break
        default:
            break
        }
    }
    
    func validateOnChangeText() {
        switch self.validator?.check(self.text ?? "") {
        case .success:
            self.delegate?.inputViewDidChange?(self, validate: true, error: nil)
            break
        case let .failure(info)?:
            self.delegate?.inputViewDidChange?(self, validate: false, error: info)
            break
        default:
            break
        }
    }
    
    func validateOnEndEditing() {
        switch self.validator?.check(self.text ?? "") {
        case .success:
            self.delegate?.inputViewDidEndEditing?(self, validate: true, error: nil)
            break
        case let .failure(info)?:
            self.delegate?.inputViewDidEndEditing?(self, validate: false, error: info)
            break
        default:
            break
        }
    }
    
}

// MARK: - Add Done Button
extension FloatingPlaceholderInputView {
    
    private func addDoneButtonOnKeyboard() {
        
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))
        doneToolbar.tintColor = self.textColor
        doneToolbar.isTranslucent = false
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: self.keyboardToolTitle ?? "Done", style: .plain, target: self, action: #selector(self.doneButtonAction))
        doneButton.setTitleTextAttributes(
            [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: self.keyboardToolTitleColor ?? .black
            ],
            for: .normal)
        
        doneToolbar.items = [flexSpace, doneButton]
        doneToolbar.sizeToFit()
        
        self.sqTextField.inputAccessoryView = doneToolbar
        self.sqTextField.returnKeyType = .done
    }
    
    @objc func doneButtonAction() {
        _ = self.textFieldShouldReturn(self.sqTextField)
    }
    
}
