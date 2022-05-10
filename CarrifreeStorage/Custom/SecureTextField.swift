//
//  ScureTextField.swift
//  Carrifree
//
//  Created by plattics-kwon on 2020/11/16.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit

class SecureTextField: UITextField {

    private var barier = true

    override var isSecureTextEntry: Bool {
        didSet {
            if isFirstResponder {
                _ = becomeFirstResponder()
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        if isSecureTextEntry, let text = self.text, barier {
            deleteBackward()
            insertText(text)
        }
        barier = !isSecureTextEntry
        return success
    }

}
