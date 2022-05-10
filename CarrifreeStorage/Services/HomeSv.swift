//
//  MainSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/20.
//
//
//  💬 ## HomeSv ##
//  💬 메인(홈)화면에서 필요한 정보를 요청하는 API 모음
//

import Foundation
import Alamofire
import SwiftyJSON

class HomeSv: Service {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - 배너 요청
    /// 배너 요청
    func getBanners(bannerCase: String, bannerGroup: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      CD_CATEGORY                             배너 앱 분류 1 (배너가 보여질 앱의 종류)
        //      BRD_GROUP                               배너 앱 분류 2 (배너 그룹)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (bannerList)
        //      BOARD_SEQ               <Number>        게시판 시퀀스
        //      BOARD_TITLE             <String>        게시판 제목
        //      BANNER_ATTACH_INFO      <String>        이미지 경로
        //      BRD_ATTACH_GRP_SEQ      <Number>        게시판 메인 노출 이미지
        //      ATTACH_SEQ              <Number>        파일 시퀀스
        //      LINK_URL                <String>        연결 링크 정보
        //      BACKGROUND_COLOR        <String>        배경 색상 코드
        //      resCd                   <String>        결과 코드
        //
        //------------------------------------------------------------- //
        
        let param: [String: String] = [
            "CD_CATEGORY": bannerCase,
            "BRD_GROUP": bannerGroup
        ]
        
        let url = getRequestUrl(body: "/sys/contents/appMain/bannerList.do")
        apiManager.request(api: .getBanners, url: url, parameters: param, completion: completion)
    }

    // MARK: 메인(홈)화면 정보 요청
    func getMainTapInfo(completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //          USER_ID                 사용자 ID
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          (tabCountMap)
        //          reserveCnt              예약 카운트
        //          todayTransCnt           오늘 운송 카운트
        //          userReqCnt              견적 요청 카운트
        //
        //          (buttonCountMap)
        //          vechileInfoCnt          차량 정보 카운트
        //          priceInfoCnt            운임정보 카운트
        //
        //          (saleMap)
        //          TODAY_HINT_SALES        오늘의 매출 예상 금액
        //          TO_MONTH_HINT_SALES     이번달 매출 금액
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_ID": _user.id,
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/basicMain/app/getSaveActionV2Cnt.do")
        apiManager.request(api: .main, url: url, headers: headers, parameters: param, completion: completion)
    }
}
