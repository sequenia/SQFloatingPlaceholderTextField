//
//  File.swift
//  
//
//  Created by Olga Lidman on 20.10.2020.
//

import Foundation

// MARK: - Class
open class SQTextFieldBaseFormatter: SQTextFieldFormatter {
    
// MARK: - Properties
    public var onlyString: String?
    public var prefix: String?
    
// MARK: - Check
    public func check(_ text: String) -> String {
        self.onlyString = text
        return text
    }
}
