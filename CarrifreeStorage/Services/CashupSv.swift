//
//  CashupSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/18.
//
//
//  ๐ฌ ## CashupSv ##
//  ๐ฌ ๋งค์ถ/์ ์ฐ ๊ด๋ จ API ๋ชจ์
//

import Foundation
import Alamofire
import SwiftyJSON

class CashupSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }

    // MARK: ์ ๋งค์ถ ์กฐํ
    func getMonthlySales(month: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                ์ ์  ์ํ์ค
        //      MONTHS                  ๊ฒ์ ์
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (getTotMonthSaleItem)
        //      USER_FEE                <String>        ์ ์ด ์์
        //      PAYBACK_USER_FEE        <String>        ์ ์ฐ ๋ฐ์ ๊ธ์ก
        //
        //      [getMonthSaleList]
        //      ORDER_KIND_TEXT         <String>        ์ฃผ๋ฌธ ์ข๋ฅ
        //      TAKE_FEE                <String>        ์ฐพ๋ ๋ณด๊ด์ฌ์์ ์์๋ฃ
        //      ING_DATE                <Number>        ๋ณด๊ด ์๊ฐ
        //      PAYBACK_USER_FEE        <String>        ์ ์ฐ ๊ธ์ก
        //      DAY_TEXT                <String>        ๋ ์ง
        //      DELIVERY_NO             <String>        ์ฃผ๋ฌธ ๋ฒํธ
        //      ORDER_SEQ               <Number>        ์ฃผ๋ฌธ ์ํ์ค
        //      USER_NAME               <String>        ๋ณด๊ด์ฌ์์ ์ํธ๋ช
        //      BOX_CNT                 <Number>        ๋ณด๊ด ๊ฑด์
        //      ENTRUST_FEE             <String>        ๋งก๊ธฐ๋ ๋ณด๊ด์ฌ์์ ์์๋ฃ
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
