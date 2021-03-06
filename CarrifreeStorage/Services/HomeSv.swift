//
//  MainSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/20.
//
//
//  ๐ฌ ## HomeSv ##
//  ๐ฌ ๋ฉ์ธ(ํ)ํ๋ฉด์์ ํ์ํ ์ ๋ณด๋ฅผ ์์ฒญํ๋ API ๋ชจ์
//

import Foundation
import Alamofire
import SwiftyJSON

class HomeSv: Service {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - ๋ฐฐ๋ ์์ฒญ
    /// ๋ฐฐ๋ ์์ฒญ
    func getBanners(bannerCase: String, bannerGroup: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      CD_CATEGORY                             ๋ฐฐ๋ ์ฑ ๋ถ๋ฅ 1 (๋ฐฐ๋๊ฐ ๋ณด์ฌ์ง ์ฑ์ ์ข๋ฅ)
        //      BRD_GROUP                               ๋ฐฐ๋ ์ฑ ๋ถ๋ฅ 2 (๋ฐฐ๋ ๊ทธ๋ฃน)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (bannerList)
        //      BOARD_SEQ               <Number>        ๊ฒ์ํ ์ํ์ค
        //      BOARD_TITLE             <String>        ๊ฒ์ํ ์ ๋ชฉ
        //      BANNER_ATTACH_INFO      <String>        ์ด๋ฏธ์ง ๊ฒฝ๋ก
        //      BRD_ATTACH_GRP_SEQ      <Number>        ๊ฒ์ํ ๋ฉ์ธ ๋ธ์ถ ์ด๋ฏธ์ง
        //      ATTACH_SEQ              <Number>        ํ์ผ ์ํ์ค
        //      LINK_URL                <String>        ์ฐ๊ฒฐ ๋งํฌ ์ ๋ณด
        //      BACKGROUND_COLOR        <String>        ๋ฐฐ๊ฒฝ ์์ ์ฝ๋
        //      resCd                   <String>        ๊ฒฐ๊ณผ ์ฝ๋
        //
        //------------------------------------------------------------- //
        
        let param: [String: String] = [
            "CD_CATEGORY": bannerCase,
            "BRD_GROUP": bannerGroup
        ]
        
        let url = getRequestUrl(body: "/sys/contents/appMain/bannerList.do")
        apiManager.request(api: .getBanners, url: url, parameters: param, completion: completion)
    }

    // MARK: ๋ฉ์ธ(ํ)ํ๋ฉด ์ ๋ณด ์์ฒญ
    func getMainTapInfo(completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //          USER_ID                 ์ฌ์ฉ์ ID
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //          (tabCountMap)
        //          reserveCnt              ์์ฝ ์นด์ดํธ
        //          todayTransCnt           ์ค๋ ์ด์ก ์นด์ดํธ
        //          userReqCnt              ๊ฒฌ์  ์์ฒญ ์นด์ดํธ
        //
        //          (buttonCountMap)
        //          vechileInfoCnt          ์ฐจ๋ ์ ๋ณด ์นด์ดํธ
        //          priceInfoCnt            ์ด์์ ๋ณด ์นด์ดํธ
        //
        //          (saleMap)
        //          TODAY_HINT_SALES        ์ค๋์ ๋งค์ถ ์์ ๊ธ์ก
        //          TO_MONTH_HINT_SALES     ์ด๋ฒ๋ฌ ๋งค์ถ ๊ธ์ก
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
