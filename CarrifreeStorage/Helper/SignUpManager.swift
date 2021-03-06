//
//  SignUpManager.swift
//  Carrifree
//
//  Created by plattics-kwon on 2020/11/11.
//  Copyright ยฉ 2020 plattics. All rights reserved.
//
//
//  ๐ฌ SignUpManager
//  ID, Password์ ์ ํจ์ฑ์ ๊ฒ์ฌํจ
//

import Foundation

class SignUpManager {
    
    let minIdLength: Int = 5
    var currentId: String = ""
    var checkedIds: [String]
    var currentPw: String
    var pwAvailable: Bool
    var pwSame: Bool
    
    init() {
        checkedIds = []
        currentPw = ""
        pwAvailable = false
        pwSame = false
    }
    
    
    func passwordVerification(pw: String, completion: ((Bool, String) -> Void)?) {
        currentPw = pw
        pwAvailable = false
        
        if (6 ... 12 ~= pw.count) == false {
            completion?(false, _strings[.alertIncorrectPasswordLength])
            return
        }
        
        let regexLowerAlphabet = try? NSRegularExpression(pattern: "[a-z]+", options: .caseInsensitive)                                         // ์ํ๋ฒณ ์๋ฌธ์ ๊ฒ์ถ ์ ๊ท์
        let regexUpperAlphabet = try? NSRegularExpression(pattern: "[A-Z]+", options: .caseInsensitive)                                         // ์ํ๋ฒณ ๋๋ฌธ์ ๊ฒ์ถ ์ ๊ท์
        let regexNumber = try? NSRegularExpression(pattern: "[0-9]+", options: .caseInsensitive)                                                // ์ซ์ ๊ฒ์ถ ์ ๊ท์
//        let regexSpecial = try? NSRegularExpression(pattern: "[`~!@#$%^&*()\\-_=+\\[{\\]}\\\\|;:'\",<.>/?//]+", options: .caseInsensitive)      // ํน์๋ฌธ์ ๊ฒ์ถ ์ ๊ท์
        let regexSpecial = try? NSRegularExpression(pattern: "[!@#$%^&*]+", options: .caseInsensitive)                                          // ํน์๋ฌธ์ ๊ฒ์ถ ์ ๊ท์

        // ์ํ๋ฒณ ๊ฒ์ถ
        let nsPw = pw as NSString
        let lowerAlphabetResult = regexLowerAlphabet?.matches(in: pw, options: [], range: NSRange(location: 0, length: nsPw.length)).map { nsPw.substring(with: $0.range) }
        let upperAlphabetResult = regexUpperAlphabet?.matches(in: pw, options: [], range: NSRange(location: 0, length: nsPw.length)).map { nsPw.substring(with: $0.range) }
        
        if ((lowerAlphabetResult?.count ?? 0) == 0) && ((upperAlphabetResult?.count ?? 0) == 0) {
            completion?(false, _strings[.alertNeedAlphabet])
            return
        }
        _log.logWithArrow("Lower alphabets", lowerAlphabetResult?.debugDescription ?? "not exist..")
        _log.logWithArrow("Upper alphabets", upperAlphabetResult?.debugDescription ?? "not exist..")

        // ์ซ์ ๊ฒ์ถ
        let numberResult = regexNumber?.matches(in: pw, options: [], range: NSRange(location: 0, length: nsPw.length)).map {
            nsPw.substring(with: $0.range)
        }
        
        if (numberResult?.count ?? 0) == 0 {
            completion?(false, _strings[.alertNeedNumber])
            return
        }
        _log.logWithArrow("Numbers", numberResult?.debugDescription ?? "not exist..")
        
        let specialCharResult = regexSpecial?.matches(in: pw, options: [], range: NSRange(location: 0, length: nsPw.length)).map {
            nsPw.substring(with: $0.range)
        }
        
        if (specialCharResult?.count ?? 0) == 0 {
            completion?(false, _strings[.alertNeedSpecialChar])
            return
        }
        _log.logWithArrow("Special characters", specialCharResult?.debugDescription ?? "not exist..")
        
        currentPw = _utils.encodeToMD5(pw: pw)
//        currentPw = pw
        pwAvailable = true
        completion?(true, _strings[.alertPasswordAvailable])
    }
    
    func passwordCompare(pw01: String, pw02: String) -> Bool {
        pwSame = (pw01 == pw02)
        return pwSame
    }
    
    func isAvailableId(id: String?) -> Bool {
        for checkedId in checkedIds {
            if checkedId == id { return true }
        }
        
        return false
    }
    
}
