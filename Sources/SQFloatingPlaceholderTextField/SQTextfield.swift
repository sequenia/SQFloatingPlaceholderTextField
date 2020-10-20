//
//  MaskedTextField.swift
//  SQFloatingPlaceholderTextField
//
//  Created by Olga Lidman on 05.10.2020.
//

import Foundation
import UIKit

public enum LanguageCode: String {
    
    case en = "en-US"
    case ru = "ru-RU"
}

open class SQTextfield: UITextField {

    open var languageCode: LanguageCode? = .ru {
        didSet {
            if self.isFirstResponder {
                self.resignFirstResponder()
                self.becomeFirstResponder()
            }
        }
    }
    
    open override var textInputMode: UITextInputMode? {
        if let languageCode = self.languageCode {
            for mode in UITextInputMode.activeInputModes {
                if let language = mode.primaryLanguage {
                    if language == languageCode.rawValue {
                        return mode
                    }
                }
            }
        }
        return super.textInputMode
    }
}
