//
//  FloatingPlaceholderInputView.swift
//  SQFloatingPlaceholderTextField
//
//  Created by Olga Lidman on 05.10.2020.
//

import UIKit

fileprivate struct Constants {
    
    static let kEnglishPrefix = "en"
    static let kClearButtonWidth: CGFloat = 30
}

// MARK: - Input Data Delegate
public protocol SQInputDataDelegate: class {

    func updateInputData(_ text: String?)
}

// MARK: - FloatingPlaceholderInputView class
open class FloatingPlaceholderInputView: UIView {
  
    
// MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet private weak var maskedTextField: SwiftMaskTextfield!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    
    @IBOutlet private weak var buttonWidth: NSLayoutConstraint!
    
// MARK: - Text
    open var text: String? {
        set { self.maskedTextField.text = newValue }
        get { return self.maskedTextField.text }
    }

// MARK: - UI Properties / Colors
    @IBInspectable
    open var inputTintColor: UIColor {
        set { self.maskedTextField.tintColor = newValue }
        get { return self.maskedTextField.tintColor }
    }
    
    @IBInspectable
    open var textColor: UIColor {
        set { self.maskedTextField.textColor = newValue }
        get { return self.maskedTextField.textColor ?? .black }
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
    
// MARK: - Pattern
    /* Pattern Rules
     * Letters And Digits Replacement Char: "*"
     * Any Letter Replecement Char: "@"
     * Lowercase Letter Replecement Char: "a"
     * Uppercase Letter Replecement Char: "A"
     * Digits Replecement Char: "#"
     */
    @IBInspectable
    open var formatPattern: String = "" {
        didSet { self.maskedTextField.formatPattern = self.formatPattern }
    }
    
// MARK: - Prefix
    @IBInspectable
    open var prefix: String = ""
        
// MARK: - Fonts
    open var textFont: UIFont {
        set { self.maskedTextField.font = newValue
              self.placeholderLabel.font = newValue
        }
        get { return self.maskedTextField.font ?? UIFont.systemFont(ofSize: 16) }
    }
    
    open var placeholderFont: UIFont {
        set { self.placeholderLabel.font = newValue }
        get { return self.placeholderLabel.font }
    }
    
// MARK: - Data
    var delegate: SQInputDataDelegate?
    var type: SQTextFieldType?
    
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
        self.maskedTextField.delegate = self
        self.maskedTextField.addTarget(self, action: #selector(textFieldDidChange),
                                       for: .editingChanged)
    }
    
// MARK: - Configure
    open func configure(type: SQTextFieldType,
                        delegate: SQInputDataDelegate?,
                        value: String? = nil,
                        placeholder: String) {
        self.delegate = delegate
        self.setPlaceholder(placeholder)
        self.setTextFieldText(value, appearPlaceholder: false)
        self.setType(type)
    }
// MARK: - Setters / Placeholder
    private func setPlaceholder(_ placeholder: String) {
        self.placeholderLabel.text = placeholder
        self.maskedTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.font: self.textFont, .foregroundColor: self.placeholderColor])
    }
// MARK: - Type
    private func setType(_ type: SQTextFieldType) {
        self.type = type
        switch type {
        case .cardNumber, .phoneNumber, .numbers:
            self.addDoneButtonOnKeyboard()
        case .email, .password:
            self.maskedTextField.languagePrefix = Constants.kEnglishPrefix
        default:
            break
        }
        
        self.maskedTextField.keyboardType = type.keyboardType
        self.maskedTextField.autocapitalizationType = type.capitalization
    }
    
// MARK: - Text
    private func setTextFieldText(_ text: String?, appearPlaceholder: Bool) {
        guard let fieldText = text, fieldText != "" else {
            self.clearButton.isHidden = true
            return }
        self.text = fieldText
        self.clearButton.isHidden = false
        self.appearPlaceholder(animate: appearPlaceholder)
        self.delegate?.updateInputData(self.text)
    }
    
// MARK: - Actions
    @IBAction func onClearButtonClicked(_ sender: UIButton) {
        self.clearTextField()
    }
    
    @objc func textFieldDidChange() {
        
        if self.text?.count != 0 {
            if self.placeholderLabel.isHidden == true {
                self.appearPlaceholder(animate: true)
            }
        }
        
        if self.text?.count == 0 {
            self.placeholderLabel.isHidden = true
        }
        
        if self.prefix != "", self.text?.count ?? 0 <= self.prefix.count {
            self.setTextFieldText(self.prefix, appearPlaceholder: false)
        }

        if self.text != "" {
            self.clearButton.isHidden = false
        } else {
            self.clearButton.isHidden = true
        }
        
        if self.text?.count ?? 0 > self.maskedTextField.maxLength {
            if let text = self.text {
                self.text = String(text.dropLast())
                return
            }
        }
        
        self.delegate?.updateInputData(self.text)
    }
    
    private func clearTextField() {
        self.text = nil
        self.placeholderLabel.isHidden = true
        self.clearButton.isHidden = true
        self.maskedTextField.resignFirstResponder()
        self.delegate?.updateInputData(nil)
    }
    
// MARK: - Animate Placeholder Appearance
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

// MARK: - UITextField Delegate
extension FloatingPlaceholderInputView: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.prefix != "" {
            if self.text == "" {
                self.setTextFieldText(self.prefix, appearPlaceholder: true)
            }
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.delegate?.updateInputData(self.text)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" || textField.text == self.prefix  {
            self.clearTextField()
        }
        self.delegate?.updateInputData(textField.text)
    }
    
}

// MARK: - Add Done Button
extension FloatingPlaceholderInputView {
    
    private func addDoneButtonOnKeyboard() {
        
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))
        doneToolbar.tintColor = self.textColor
        doneToolbar.isTranslucent = false
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneButtonAction))
        doneButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 16, weight: .medium)], for: .normal)
        
        doneToolbar.items = [flexSpace, doneButton]
        doneToolbar.sizeToFit()
        
        self.maskedTextField.inputAccessoryView = doneToolbar
        self.maskedTextField.returnKeyType = .done
    }
    
    private func removeDoneButton() {
        self.maskedTextField.inputAccessoryView = UIView()
    }
    
    @objc func doneButtonAction() {
        _ = self.textFieldShouldReturn(self.maskedTextField)
    }
}
