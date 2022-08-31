//
//  ChatLogController+Extention.swift
//  ChatApp
//
//  Created by Admin on 29/08/22.
//

import UIKit

extension ChatLogController {
    
    func initializeHideKeyboard() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissMyKeyboard() {
        view.endEditing(true)
    }
}
