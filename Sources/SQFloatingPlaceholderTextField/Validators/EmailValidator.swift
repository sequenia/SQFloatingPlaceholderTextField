//
//  File.swift
//  
//
//  Created by Olga Lidman on 20.10.2020.
//

import Foundation

// MARK: - Class
class SQEmailValidator: SQTextFieldValidator {
   
// MARK: - Properties
    var required: Bool
    
// MARK: - Init
    init(required: Bool) {
        self.required = required
    }
    
// MARK: - Check
    func check(_ text: String) -> TextValidationResult {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let validate = emailTest.evaluate(with: text)
        
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
