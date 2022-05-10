//
//  LoadVm.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/21.
//

import Foundation
import SwiftyJSON

class LoadVm {
    
    func getUpdateInfo(platform: String = CarrifreeAppType.appStorage.rawValue, handler: @escaping ((Bool) -> Void)) {
        //-------------------------- Request -------------------------- //
        //
        //         PLATFORM_TYPE            단말기 타입 (I: iOS, A: Android)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          APP_VERSION             마지막 강제 업데이트 버전
        //          DATE_C                  마지막 강제 업데이트 날짜
        //
        //------------------------------------------------------------- //
        
        let currentVersion = _utils.getAppVersionInt()
        
        _cas.load.getUpdateInfo(platform: platform) { (success, json) in
            guard let json = json else { return }
            
            let requestTitle = "[업데이트 정보 요청]"
            let msg = json["resMsg"].stringValue
            
            // 요청 실패
            guard json["resCd"].stringValue == "0000" else {
                _log.logWithArrow("\(requestTitle) failed", msg)
                var message = msg
                if message.isEmpty { message = "\(_strings[.alertUpdateInfoLoadFailed])\n\(_strings[.plzTryAgain])" }
                let alert = _utils.createSimpleAlert(title: msg, message: "", buttonTitle: _strings[.ok])
                _utils.topViewController()?.present(alert, animated: true)
                return
            }
            
            // 업데이트 정보
            let lastVersion = _utils.getAppVersionInt(version: json["APP_VERSION"].stringValue)
            let _ = json["DATE_C"].stringValue
            
            // 서버에서 받은 앱버전이 현재 앱버전 보다 크면 스토어로 이동시킴(필수 업데이트)
            if lastVersion > currentVersion {
                
                /*
                let buttonTitle = _strings[.ok]
                let alertMsg = String(format: _strings[.alertNeedUpdate], currentVersion, buttonTitle)
                let alert = _utils.createSimpleAlert(title: _strings[.requiredUpdate], message: alertMsg, buttonTitle: buttonTitle) { (_) in
                    self.openAppStore(urlStr: _identifiers[.appstoreUrl])
                }
                _utils.topViewController()?.present(alert, animated: true)
                */
                
                handler(true)
            } else {
                handler(false)
            }
            
        }
    }
}
