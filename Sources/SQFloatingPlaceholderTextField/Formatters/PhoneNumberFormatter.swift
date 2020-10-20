//
//  File.swift
//  
//
//  Created by Olga Lidman on 20.10.2020.
//

import UIKit

// MARK: - Class
class SQPhoneNumberFormatter: SQTextFieldFormatter {
    
// MARK: - Properties
    var onlyString: String?
    var prefix: String?
    
// MARK: - Check
    func check(_ text: String) -> String {
        let obj = SHSPhoneNumberFormatter()
        obj.addOutputPattern(" ### ### ## ##", forRegExp: "^*[0-689]\\d*$")
        obj.prefix = "+" + (self.prefix ?? "7")

        let text = obj.values(for: text)
        let str = text["text"] as? String ?? ""
        if str == obj.prefix {
            self.onlyString = ""
            return obj.prefix ?? ""
        }

        let resultStr = obj.digitsOnlyString(from: text["text"] as? String  ?? "")
        if resultStr.hasPrefix(self.prefix ?? "") {
            let prefixIndex = resultStr.index(resultStr.startIndex, offsetBy: self.prefix?.count ?? 0)
            self.onlyString = String(resultStr[prefixIndex...])
        }

        return text["text"] as? String ?? ""
    }
    
}
