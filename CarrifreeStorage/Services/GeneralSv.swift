//
//  GeneralSv.swift
//  CarrifreeStorage
//
//  Created by orca on 2022/03/08.
//
//
//  π¬ ## GeneralSv ##
//  π¬ μ¬λ¬ νλ©΄μμ μ°μ΄λ API λͺ¨μ
//

import Foundation
import SwiftyJSON
import Alamofire

class GeneralSv: Service {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - μ± μλ°μ΄νΈ μ λ³΄ μ‘°ν
    /// μ± μλ°μ΄νΈ μ λ³΄ μ‘°ν
    func getUpdateInfo(platform: String = CarrifreeAppType.appStorage.rawValue, handler: @escaping ((Bool) -> Void)) {
        //-------------------------- Request -------------------------- //
        //
        //         PLATFORM_TYPE            λ¨λ§κΈ° νμ (I: iOS, A: Android)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          APP_VERSION             λ§μ§λ§ κ°μ  μλ°μ΄νΈ λ²μ 
        //          DATE_C                  λ§μ§λ§ κ°μ  μλ°μ΄νΈ λ μ§
        //
        //------------------------------------------------------------- //
        
        let currentVersion = _utils.getAppVersionInt()
        
        _cas.load.getUpdateInfo(platform: platform) { (success, json) in
            guard let json = json else { return }
            
            let requestTitle = "[μλ°μ΄νΈ μ λ³΄ μμ²­]"
            let msg = json["resMsg"].stringValue
            
            // μμ²­ μ€ν¨
            guard json["resCd"].stringValue == "0000" else {
                _log.logWithArrow("\(requestTitle) failed", msg)
                var message = msg
                if message.isEmpty { message = "\(_strings[.alertUpdateInfoLoadFailed])\n\(_strings[.plzTryAgain])" }
                let alert = _utils.createSimpleAlert(title: msg, message: "", buttonTitle: _strings[.ok])
                _utils.topViewController()?.present(alert, animated: true)
                return
            }
            
            // μλ°μ΄νΈ μ λ³΄
            let lastVersion = _utils.getAppVersionInt(version: json["APP_VERSION"].stringValue)
            let _ = json["DATE_C"].stringValue
            
            // μλ²μμ λ°μ μ±λ²μ μ΄ νμ¬ μ±λ²μ  λ³΄λ€ ν¬λ©΄ μ€ν μ΄λ‘ μ΄λμν΄(νμ μλ°μ΄νΈ)
            let needUpdate = lastVersion > currentVersion
            handler(needUpdate)
        }
    }
    
    // test!
    func testLogin(completion: ResponseString = nil) {
        _cas.load.testLogin() { (success, json) in
            var msg: String = ""
            if let json = json, true == success {
                _user.token = json["sha_token"].stringValue
                _user.id = json["memberInfo"]["user_ID"].stringValue
                _user.seq = json["memberInfo"]["user_SEQ"].stringValue
                _user.masterSeq = json["memberInfo"]["master_SEQ"].stringValue
            } else {
                msg = ApiManager.getFailedMsg(defaultMsg: "", json: json)
            }
            
            completion?(success, msg)
        }
    }
    
    /// λ©μΈ(ν)νλ©΄ μ λ³΄ μμ²­
    func getMainTapInfo(completion: ResponseString = nil) {
        _cas.home.getMainTapInfo() { (success, json) in
            
            if let json = json, true == success {
                let requestTitle = "[λ©μΈ(ν)νλ©΄ μ λ³΄ μμ²­]"
                let msg = json["resMsg"].stringValue
                
                guard json["resCd"].stringValue == "0000" else {
                    _log.logWithArrow("\(requestTitle) failed", msg)
                    
                    var errMsg = "\(_strings[.alertFailedToGetBizInto]) \(_strings[.runAgain])"
                    if msg.count > 0 { errMsg += "\n(\(msg))" }
                    
                    completion?(false, msg)
                    return
                }
                
                let approved = json["adminCheckYn"]["ADMIN_CHECK_YN"].stringValue
                let stored = json["bizCheckYn"]["BIZ_CHECK_YN"].stringValue
                var monthlySales = json["saleMap"]["TO_MONTH_HINT_SALES"].stringValue
                if monthlySales.isEmpty { monthlySales = "0" }
                
                /*
                let tapCountMap = json["tabCntMap"]
                let storage = tapCountMap["saveCnt"].intValue
                let cBase = tapCountMap["reqSaveCnt"].intValue
                
                let bottomCountMap = json["bottomCntMap"]
                let providerInfo = bottomCountMap["baseInfoCnt"].intValue
                let storeInfo = bottomCountMap["vechileInfoCnt"].intValue
                let holidayInfo = bottomCountMap["holidayInfoCnt"].intValue
                let costInfo = bottomCountMap["priceInfoCnt"].intValue
                
                let saleMap = json["saleMap"]
                let todaySales = _utils.getIntFromDelimiter(str: saleMap["TODAY_HINT_SALES"].string)
                let monthlySales = _utils.getIntFromDelimiter(str: json["TO_MONTH_HINT_SALES"].string)
                */
                
                
                if approved == "Y" {
                    _user.approval = .approved
                } else if approved == "D" {
                    _user.approval = .wating
                } else if approved == "N" {
                    _user.approval = .beforeRequest
                } else {
                    _user.approval = .beforeRequest
                }
                
                _user.stored = (stored == "Y")
                _user.monthlySales = monthlySales
                
                _log.log("\(requestTitle) success")
                completion?(true, "")

            } else {
                
            }
            
        }
    }
    
    // MARK: - λ§€μ₯ λΈμΆ/λΉλΈμΆ μν μ‘°ν
    /// λ§€μ₯ λΈμΆ/λΉλΈμΆ μν μ‘°ν
    func getAppearance(completion: ResponseJson = nil) {
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/getVisibleInfo.do")
        apiManager.request(api: .getAppearance, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: λΈμΆ/λΉλΈμΆ μ€μ 
    /// λΈμΆ/λΉλΈμΆ μ€μ 
    func setAppearance(appear: Bool, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                μ μ  μνμ€
        //      VISIBLE_YN              λΈμΆ/λΉλΈμΆ ("Y"/"N")
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response -------.------------------ //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        var appearStr = "Y"
        if appear == false { appearStr = "N" }
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq,
            "AVAILABLE_YN": appearStr
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/setVisibleInfo.do")
        apiManager.request(api: .setAppearance, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    func getPicture(url: String, completion: ResponseImg) {
        guard let headers = getHeader() else { return }
        apiManager.requestDownload(headers: headers, url: url, completion: completion)
    }
}
