//
//  File.swift
//  
//
//  Created by Olga Lidman on 19.10.2020.
//

import Foundation

//MARK: - Validator Protocol
public protocol SQTextFieldValidator: class {
    
    var required: Bool { get }
    func check(_ text: String) -> TextValidationResult
    
}

//MARK: - Text Validation Result Enum
public enum TextValidationResult {
    
    case success
    case failure(info: String?)
    
}

//MARK: - Validation Errors Enum
public struct ValidationErrors {
    
    var requiredError: String    = "Поле не может быть пустым"
    var wrongFormatError: String = "Неверный формат"
    
    init(){}
    
    init(requiredError: String,
         wrongFormatError: String) {
        self.requiredError = requiredError
        self.wrongFormatError = wrongFormatError
    }
}


