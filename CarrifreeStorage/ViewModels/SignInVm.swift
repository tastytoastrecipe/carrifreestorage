//
//  SignInVm.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/17.
//
//
//  ๐ฌ SigninVm
//  ๋ก๊ทธ์ธ view model
//

import Foundation

class SigninVm {
    
    init() {
    }
    
    func signin(id: String, pw: String, completion: ResponseString = nil) {
        
        // ๋ก๊ทธ์ธ ์์ฒญ
//        let encodedPw = _utils.encodeToMD5(pw: pw)
        _cas.signin.signin(id: id, pw: pw) { (success, json) in
            var msg = ""
            if let json = json, true == success {
                _user.saveData(userId: id, userPw: pw, json: json)
                
                let deviceAuthUrl = json["resUrl"].stringValue
                guard false == deviceAuthUrl.isEmpty else {
                    completion?(false, "๋ก๊ทธ์ธํ์ง ๋ชปํ์ต๋๋ค.\n(๋๋ฐ์ด์ค ์ธ์ฆ url์ ๋ฐ์ง ๋ชปํ์ต๋๋ค)")
                    return
                }
                
                // ๋๋ฐ์ด์ค ์ ๋ณด ์ ์ก
                _cas.signin.sendDeviceInfo(userSeq: _user.seq, url: deviceAuthUrl, userName: _user.name) { (success, json) in
                    if success {
                        _user.signIn = true
                        completion?(true, "")
                    } else {
                        let failedMsg = ApiManager.getFailedMsg(defaultMsg: "๋ก๊ทธ์ธํ์ง ๋ชปํ์ต๋๋ค.", json: json)
                        completion?(false, failedMsg)
                    }
                }
            } else {
                _utils.removeIndicator()
                msg = ApiManager.getFailedMsg(defaultMsg: "๋ก๊ทธ์ธํ์ง ๋ชปํ์ต๋๋ค.", json: json)
                completion?(success, msg)
            }
        }
    }
    
}
