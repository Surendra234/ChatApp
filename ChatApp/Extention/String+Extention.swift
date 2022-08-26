//
//  String+Extention.swift
//  ChatApp
//
//  Created by Admin on 21/08/22.
//

import Foundation

extension String {
    
    func isValidUsername() -> Bool {
        let usernameRegexPattern =  "^[a-zA-Z0-9]([._-](?![._-])|[a-zA-Z0-9]){2,18}[a-zA-Z0-9]$"
        return applyUserDetailOnRegexPattern(regexStr: usernameRegexPattern)
    }
    
    func isValidEmail() -> Bool {
        let emailRegexPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return applyUserDetailOnRegexPattern(regexStr: emailRegexPattern)
    }
    
    func isValidPassword(min: Int = 8, max: Int = 8) -> Bool {
        var passwordRegexPattern = ""
        if min >= 8 {
            passwordRegexPattern = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{\(min),}$"
        }
        else {
            passwordRegexPattern = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{\(min),\(max)}$"
        }
        return applyUserDetailOnRegexPattern(regexStr: passwordRegexPattern)
    }
    
    
    func applyUserDetailOnRegexPattern(regexStr: String) -> Bool {
        let trimedString = self.trimmingCharacters(in: .whitespaces)
        let validOtherString = NSPredicate(format: "SELF MATCHES %@", regexStr)
        let isValidOtherString = validOtherString.evaluate(with: trimedString)
        
        return isValidOtherString
    }
}
