//
//  GeneralSv.swift
//  CarrifreeStorage
//
//  Created by orca on 2022/03/08.
//
//
//  💬 ## GeneralSv ##
//  💬 여러 화면에서 쓰이는 API 모음
//

import Foundation
import SwiftyJSON
import Alamofire

class GeneralSv: Service {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - 앱 업데이트 정보 조회
    /// 앱 업데이트 정보 조회
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
    
    /// 메인(홈)화면 정보 요청
    func getMainTapInfo(completion: ResponseString = nil) {
        _cas.home.getMainTapInfo() { (success, json) in
            
            if let json = json, true == success {
                let requestTitle = "[메인(홈)화면 정보 요청]"
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
    
    // MARK: - 매장 노출/비노출 상태 조회
    /// 매장 노출/비노출 상태 조회
    func getAppearance(completion: ResponseJson = nil) {
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/getVisibleInfo.do")
        apiManager.request(api: .getAppearance, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: 노출/비노출 설정
    /// 노출/비노출 설정
    func setAppearance(appear: Bool, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                유저 시퀀스
        //      VISIBLE_YN              노출/비노출 ("Y"/"N")
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
