//
//  File.swift
//  
//
//  Created by Olga Lidman on 20.10.2020.
//

import Foundation

// MARK: - Class
open class SQPhoneNumberValidator: SQTextFieldValidator {
    
// MARK: - Properties
    open var required: Bool
    
// MARK: - Init
    public init(required: Bool) {
        self.required = required
    }
   
// MARK: - Check
    public func check(_ text: String) -> TextValidationResult {
        let phoneRegEx = "^\\+?[78][-\\(\\ ]?\\d{3}\\)?-?\\ ?\\d{3}-?\\ ?\\d{2}-?\\ ?\\d{2}$"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        let validate = phoneTest.evaluate(with: text)
        
        if self.required {
            if text.count == 0 {
                return .failure(info: ValidationErrors().requiredError)
            }
            if validate {
                return .success
            }
            return .failure(info: ValidationErrors().wrongFormatError)
        }
        
        if validate {
            return .success
        }
        
        if text.count > 0, !validate {
            return .failure(info: ValidationErrors().wrongFormatError)
        }
        
        return .success
    }
    
}
