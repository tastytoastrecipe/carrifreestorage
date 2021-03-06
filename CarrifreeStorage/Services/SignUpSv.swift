//
//  SignUpSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/21.
//
//
//  ๐ฌ SignupSv
//  ๐ฌ ํ์๊ฐ์ ๊ด๋ จ API ๋ชจ์
//

import Foundation
import SwiftyJSON
import Alamofire

class SignupSv: Service {

    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - ID ์ ํจ์ฑ ํ์ธ
    func isAvailableId(id: String, completion: ResponseJson) {
        
        let param: Parameters = [
            "USER_ID": id,
            "USER_TYPE": CarrifreeAppType.appStorage.user
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/duplicateMember.do")
        apiManager.request(api: .idDuplicationCheck, url: url, parameters: param, completion: completion)
    }
    
    // MARK: - ์ฝ๊ด ์กฐํ
    func requestTerms(termType: String = "", completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      TERMS_TYPE              ์ฝ๊ด ์ข๋ฅ, null:์ ์ฒด์ฝ๊ด์กฐํ (TermCase.type)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (termsList)
        //      BOARD_SEQ               ์ฝ๊ด ์ํ์ค
        //      BOARD_TITLE             ์ฝ๊ด ์ ๋ชฉ
        //      BOARD_MEMO              ์ฝ๊ด ๋ด์ฉ
        //      DIVISION_YN             ํ์/์ ํ ์ฌํญ
        //
        //------------------------------------------------------------- //
        
        let url = getRequestUrl(body: "/sys/contents/appAuth/getAllTerms.do")
        
        if termType.isEmpty {
            apiManager.requestSimpleGetJson(api: .getTerms, url: url, completion: completion)
        } else {
            let param: Parameters = ["TERMS_TYPE": termType]
            apiManager.request(api: .getTerms, url: url, parameters: param, completion: completion)
        }
    }
    
    // MARK: - ํด๋ํฐ ์ธ์ฆ ๋ฒํธ ์์ฒญ
    func requestAuth(phone: String, signup: Bool, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_HP_NO              ํธ๋ํฐ๋ฒํธ
        //      JOIN_YN                 ํ์๊ฐ์ ์ฌ๋ถ
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        var param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_HP_NO": phone
        ]
        
        if signup {
            param["JOIN_YN"] = "Y"
        }
        
        let url = getRequestUrl(body: "/sys/memberV3/app/hpAuthNSendSms.do")
        apiManager.request(api: .phoneAuth, url: url, parameters: param, completion: completion)
    }
    
    // MARK: - ํด๋ํฐ ์ธ์ฆ
    func doAuth(phone: String, authNo: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_HP_NO              ํธ๋ํฐ๋ฒํธ
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.rawValue,
            "USER_HP_NO": phone,
            "AUTH_CHECK_NO": authNo
        ]
        
        let url = getRequestUrl(body: "/sys/memberV3/app/hpConfirmCheck.do")
        apiManager.request(api: .phoneAuth, url: url, parameters: param, completion: completion)
    }
    
    
    // MARK: - ํ์๊ฐ์
    func signup(id: String, pw: String, phone: String, name: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_ID                 ํ์ ID
        //      USER_PWD                ํจ์ค์๋
        //      USER_NAME               ์ฌ์ฉ์ ์ด๋ฆ
        //      USER_HP_NO              ํธ๋ํฐ๋ฒํธ
        //      USER_TYPE               ํ์ ์ ํ(CarrifreeAppType.user)
        //      JOIN_TYPE               ๋๋ฐ์ด์ค ์ข๋ฅ (001: iOS, 002: Android)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        let param: Parameters = [
            "USER_ID": id,
            "USER_PWD": pw,
            "USER_NAME": name,
            "USER_HP_NO": phone,
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "JOIN_TYPE": "001"
        ]
        
        let url = getRequestUrl(body: "/sys/member/app/generalJoinMember.do").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if url.isEmpty { completion?(false, "ํ์๊ฐ์ ์์ฒญ url์ ์์ฑํ์ง ๋ชปํ์ต๋๋ค. ๋ค์ ์๋ํด์ฃผ์๊ธฐ ๋ฐ๋๋๋ค."); return }
        apiManager.request(api: .signup, url: url, parameters: param, completion: completion)
    }
}
