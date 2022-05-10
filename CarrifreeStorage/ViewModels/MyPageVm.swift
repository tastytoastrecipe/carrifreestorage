//
//  MyPageVm.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/20.
//

import Foundation
import SwiftyJSON

class MyPageVm {
    
    func requestWithDraw(completion: ResponseString = nil) {
        _cas.mypage.requestWithdrawal() { (success, json) in
            var msg: String = ""
            if success {
                _user.removeData()
            } else {
                msg = self.getFailedMsg(defaultMsg: _strings[.plzTryAgain], json: json)
            }
            
            completion?(success, msg)
        }
    }
    
    func getProfilePicture(completion: ResponseString = nil) {
        _cas.mypage.getProfilePicture() { (success, json) in
            var msg: String = ""
            if let json = json, true == success {
                var pictureUrl = json["USER_ATTACH_INFO"].stringValue
                let pictureSeq = json["ATTACH_GRP_SEQ"].stringValue
                
                if pictureUrl.contains("no_profileImg") { pictureUrl = "" }
                _user.profilePicture.url = pictureUrl
                _user.profilePicture.seq = pictureSeq
            } else {
                msg = self.getFailedMsg(defaultMsg: "\(_strings[.alertLoadProfilePicFailed]) \(_strings[.plzTryAgain])", json: json)
            }
            
            completion?(success, msg)
        }
    }
    
    func registerProfilePicture(attachGrpSeq: String, imgData: Data, completion: ResponseString = nil) {
        _cas.mypage.registerProfilePicture(attachGrpSeq: attachGrpSeq, imgData: imgData) { (success, json) in
            var msg: String = ""
            if success {
                
            } else {
                msg = self.getFailedMsg(defaultMsg: "\(_strings[.alertRegisterProfilePicFailed]) \(_strings[.plzTryAgain]).", json: json)
            }
            
            completion?(success, msg)
        }
    }
    
    private func getFailedMsg(defaultMsg: String, json: JSON?) -> String {
        guard let json = json else { return defaultMsg }
        
        var msg = defaultMsg
        let errMsg = json["resMsg"].stringValue
        if errMsg.count > 0 { msg += "\n(\(errMsg))" }
        else { return msg }
        
        return msg
    }
}
