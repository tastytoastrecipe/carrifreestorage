//
//  CashupSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/18.
//
//
//  💬 ## CashupSv ##
//  💬 매출/정산 관련 API 모음
//

import Foundation
import Alamofire
import SwiftyJSON

class CashupSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }

    // MARK: 월 매출 조회
    func getMonthlySales(month: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                유저 시퀀스
        //      MONTHS                  검색 월
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (getTotMonthSaleItem)
        //      USER_FEE                <String>        월 총 수입
        //      PAYBACK_USER_FEE        <String>        정산 받은 금액
        //
        //      [getMonthSaleList]
        //      ORDER_KIND_TEXT         <String>        주문 종류
        //      TAKE_FEE                <String>        찾는 보관사업자 수수료
        //      ING_DATE                <Number>        보관 시간
        //      PAYBACK_USER_FEE        <String>        정산 금액
        //      DAY_TEXT                <String>        날짜
        //      DELIVERY_NO             <String>        주문 번호
        //      ORDER_SEQ               <Number>        주문 시퀀스
        //      USER_NAME               <String>        보관사업자 상호명
        //      BOX_CNT                 <Number>        보관 건수
        //      ENTRUST_FEE             <String>        맡기는 보관사업자 수수료
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "MONTHS": month
        ]
        
        let url = getRequestUrl(body: "/sys/sales/app/getSaverMonthSaleList.do")
        apiManager.request(api: .getMonthlySales, url: url, headers: headers, parameters: param, completion: completion)
        
    }    
    
}
