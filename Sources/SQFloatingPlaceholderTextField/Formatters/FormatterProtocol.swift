//
//  File.swift
//  
//
//  Created by Olga Lidman on 19.10.2020.
//

import Foundation

public protocol SQTextFieldFormatter: class {
    
    var onlyString: String? { get set }
    var prefix: String? { get set }
    
    func check(_ text: String) -> String
}

