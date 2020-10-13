//
//  SQTextFieldType.swift
//  SQFloatingPlaceholderTextField
//
//  Created by Olga Lidman on 06.10.2020.
//

import UIKit

// MARK: - Enum Type
public enum SQTextFieldType {
    
    case cardNumber
    case phoneNumber
    case carNumber
    case numbers
    case text
    case capsText
    case nameText
    case email
    case password
    
// MARK: - Keyboard
    var keyboardType: UIKeyboardType {
        switch self {
        case .cardNumber:
            if #available(iOS 10.0, *) {
                return .asciiCapableNumberPad
            } else {
                return .default
            }
        case .phoneNumber, .numbers:
            return .phonePad
        case .carNumber:
            return .numbersAndPunctuation
        case .text, .password, .capsText, .nameText:
            return .default
        case .email:
            return .emailAddress
        }
    }
    
// MARK: - Capitalization
    var capitalization: UITextAutocapitalizationType {
        switch self {
        case .text:
            return .sentences
        case .capsText, .carNumber:
            return .allCharacters
        case .nameText:
            return .words
        default:
            return .none
        }
    }
    
//// MARK: - Mask
//    var mask: String {
//        switch self {
//        case .cardNumber:
//            return "#### #### #### ####"
//        case .phoneNumber:
//            return "+# ### ### ## ##"
//        default:
//            return ""
//        }
//    }

}

