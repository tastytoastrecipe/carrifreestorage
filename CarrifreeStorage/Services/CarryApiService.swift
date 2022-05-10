//
//  CarryRequest.swift
//  Carrifree
//
//  Created by orca on 2020/10/26.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

var _cas: CarryApiService = {
    return CarryApiService.shared
}()

class CarryApiService {
    static let shared = CarryApiService()
    
    lazy var apiManager = ApiManager()
    
    /// 로그인 관련 api service
    lazy var signin = SigninSv(apiManager: apiManager)
    
    /// 회원가입 관련 api service
    lazy var signup = SignupSv(apiManager: apiManager)
    
    /// ID 찾기 api service
    lazy var forgetId = ForgetIdSv(apiManager: apiManager)
    
    /// PW 재설정 api service
    lazy var forgetPw = ForgetPwSv(apiManager: apiManager)
    
    /// 메인(홈)화면 api service
    lazy var home = HomeSv(apiManager: apiManager)
    
    /// 로딩화면 api service
    lazy var load = LoadSv(apiManager: apiManager)
    
    /// 보관 파트너 승인 관련 api service
    lazy var registration = RegistrationSv(apiManager: apiManager)
    
    /// 매장정보 관련 api service
    lazy var storeinfo = StoreSv(apiManager: apiManager)
    
    /// 의뢰 관련 api service
    lazy var order = OrderSv(apiManager: apiManager)
    
    /// 매출 관련 api service
    lazy var cashup = CashupSv(apiManager: apiManager)
    
    /// 내 정보 관련 api service
    lazy var mypage = MyPageSv(apiManager: apiManager)
    
    /// 파일 업로드/다운로드 api service
    lazy var attach = AttachSv(apiManager: apiManager)
    
    /// 여러화면에서 쓰이는 api service
    lazy var general = GeneralSv(apiManager: apiManager)
    
    private init() {}
}
