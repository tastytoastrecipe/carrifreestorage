//
//  BankData.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/31.
//

import Foundation

struct BankData {
    var code: String
    var name: String
    var account: String
    
    init() {
        code = ""; name = ""; account = ""
    }
    
    init(code: String, name: String) {
        self.code = code; self.name = name; account = ""
    }
    
    init(code: String, name: String, account: String) {
        self.code = code; self.name = name; self.account = account
    }
}
