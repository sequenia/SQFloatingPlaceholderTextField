//
//  File.swift
//  
//
//  Created by Olga Lidman on 20.10.2020.
//

import Foundation

// MARK: - Class
open class SQTextFieldBaseValidator: SQTextFieldValidator {
    
//MARK: - Properties
    open var required: Bool

//MARK: - Init
    public init(required: Bool) {
        self.required = required
    }

//MARK: - Check
    public func check(_ text: String) -> TextValidationResult {
        if self.required {
            if text.count == 0 {
                return .failure(info: ValidationErrors().requiredError)
            } else {
                return .success
            }
        } else {
            return .success
        }
    }
}
