//
//  OrderSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/11.
//
//
//  ๐ฌ ## OrderSv ##
//  ๐ฌ ์ฃผ๋ฌธ(์๋ขฐ) ๊ด๋ จ API ๋ชจ์
//

import Foundation
import Alamofire
import SwiftyJSON

class OrderSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: ์๋ขฐ ๋ชฉ๋ก ์์ฒญ
    /// ์๋ขฐ ๋ชฉ๋ก ์์ฒญ
    func getOrders(orderCategory: String, orderStatus: String, page: Int, orderNo: String = "", orderName: String = "", completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      ENTRUST_BASE_SEQ        ์ ์  ์ํ์ค
        //      ORDER_STATUS            ์๋ขฐ ์งํ ์ํฉ (์์ฝ: 002, ๋ณด๊ด: 006, ์ฐพ์: 008)
        //      ORDER_SEQ               ์ฃผ๋ฌธ ์ํ์ค
        //      DELIVERY_NO             ์ฃผ๋ฌธ ๋ฒํธ
        //      BUYER_NAME              ๊ณ ๊ฐ ์ด๋ฆ
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      [payFinishSaveList]
        //      REAL_STORE_TIME         <Number>        ์ค์  ๋ณด๊ด ์๊ฐ(๋ถ)
        //      ORDER_DATE              <String>        ์์ฒญ ์ผ์(์-์ผ ์:๋ถ)
        //      PAY_STATUS              <String>        ๊ฒฐ์  ์ํ
        //      ATTACH_GRP_SEQ          <Number>        ์ฒจ๋ถ ํ์ผ ๊ทธ๋ฃน ์ํ์ค
        //      ENTRUST_BASE_SEQ        <Number>        ๋ณด๊ด์ฌ์์ ์ํ์ค
        //      MAJOR_ATTACH_INFO       <String>        ์ฒจ๋ถ ํ์ผ ์ ๋ณด
        //      EXPECT_STORE_TIME       <Number>        ์์ฝ ๋ณด๊ด ์๊ฐ(๋ถ)
        //      ENTRUST_ADDR            <String>        ๋ณด๊ด์ ์ฃผ์
        //      PROCESS_DATE            <String>        PROCESS_DATE
        //      DELIVERY_NO             <String>        ์ฃผ๋ฌธ ๋ฒํธ
        //      ORDER_SEQ               <Number>        ์ฃผ๋ฌธ ๋ฒํธ ์ํ์ค
        //      ORDER_STATUS            <String>        ์ฃผ๋ฌธ ์ํ
        //      ORDER_KIND              <String>        ์ฃผ๋ฌธ ์ข๋ฅ
        //      BOX_CNT                 <Number>        ๋ฐ์ค ์๋(์ฃผ๋ฌธ ๊ฑด์)
        //      BUYER_NAME              <String>        ๊ณ ๊ฐ ์ด๋ฆ
        //
        //      (payFinishSaveItemCnt)
        //      BEFORE_CNT              <Number>        ๋ณด๊ด ์์ 
        //      ING_CNT                 <Number>        ๋ณด๊ด ์ค
        //      FINISH_CNT              <Number>        ๋ณด๊ด ์๋ฃ
        //      resCd                   <String>        ๊ฒฐ๊ณผ ์ฝ๋
        //
        //------------------------------------------------------------- //
        
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        var param: Parameters = [
            "ENTRUST_BASE_SEQ": _user.seq,
            "ORDER_STATUS": orderStatus
        ]
        
        if false == orderNo.isEmpty { param["DELIVERY_NO"] = orderNo }
        if false == orderName.isEmpty { param["BUYER_NAME"] = orderName }
        
//        let url = getRequestUrl(body: "/sys/payment/app/getSaverOrderInfo.do")
        let url = getRequestUrl(body: "/sys/wareHouseReq/app/getPaymentFinishSaveList.do")
        apiManager.request(api: .getOrders, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: ๋ณด๊ด ์๋ขฐ ์์ธ ์ ๋ณด ์์ฒญ
    /// ๋ณด๊ด ์๋ขฐ ์์ธ ์ ๋ณด ์์ฒญ
    func getOrderDetail(orderSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                ๋ณด๊ด์ฌ์์ ์ํ์ค
        //      ORDER_SEQ               ์ฃผ๋ฌธ(์์ฝ) ์ํ์ค
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (payFinishSaveItem)
        //      REAL_STORE_TIME         <Number>        ์ค์  ๋ณด๊ด ์๊ฐ(๋ถ)
        //      ORDER_ATTACH_GRP_SEQ    <Number>        ์ง ์ฌ์ง ๊ทธ๋ฃน ์ํ์ค
        //      ENTRUST_BASE_SEQ        <Number>        ๋ณด๊ด์ฌ์์ ์ํ์ค
        //      USER_EMAIL              <String>        ์ด๋ฉ์ผ
        //      TAKE_DATE               <String>        ์ฐพ์ ๋ ์ง(์์ฝ)
        //      ENTRUST_DATE            <String>        ๋งก๊ธด ๋ ์ง(์์ฝ)
        //      XL_TYPE                 <Number>        ๋ํ์ง
        //      OVER_AMOUNT             <Number>        ์ถ๊ฐ ์๊ธ
        //      ING_DATE                <String>        ๋งก๊ธด ๋ ์ง(์ค์ )
        //      FINISH_DATE             <String>        ์ฐพ์ ๋ ์ง(์ค์ )
        //      ORDER_STATUS            <String>        ์ฃผ๋ฌธ ์ํ
        //      L_TYPE                  <Number>        ํฐ์ง
        //      USER_HP_NO              <String>        ์ฐ๋ฝ์ฒ
        //      S_TYPE                  <Number>        ๋ฏธ๋์ง
        //      ORDER_KIND_TEXT         <String>        ์ฃผ๋ฌธ ์ข๋ฅ
        //      ORDER_DATE              <String>        ์ฃผ๋ฌธ ๋ ์ง
        //      EXPECT_STORE_TIME       <Number>        ์์ฝ ์๊ฐ(๋ถ)
        //      M_TYPE                  <Number>        ์ค๊ฐ์ง
        //      BUYER_MEMO              <String>        ์์ฒญ ์ฌํญ
        //      PAY_AMOUNT              <Number>        ๊ฒฐ์  ๊ธ์ก
        //      DELIVERY_NO             <String>        ์ฃผ๋ฌธ ๋ฒํธ
        //      ORDER_SEQ               <Number>        ์ฃผ๋ฌธ ๋ฒํธ ์ํ์ค
        //      ORDER_KIND              <String>        ์ฃผ๋ฌธ ์ข๋ฅ
        //      BUYER_NAME              <String>        ์ด๋ฆ
        //      USER_SEQ_BUYER          <Number>        ์ฃผ๋ฌธ์๋ขฐ์ ์ํ์ค
        //      TOTAL_AMOUNT            <Number>        ์ด ๊ธ์ก
        //
        //                                                          [boxList]
        //                                                          ITEM_QUANTITY   <Number>    ์ง ๊ฐฏ์
        //                                                          ITEM_KIND       <String>    ์ง ์ข๋ฅ ์ฝ๋
        //                                                          ITEM_KIND_TXT   <String>    ์ง ์ข๋ฅ
        //
        //      resCd    String        ๊ฒฐ๊ณผ ์ฝ๋
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "ORDER_SEQ": orderSeq
        ]
        
//        let url = getRequestUrl(body: "/sys/payment/app/getSaverOrderDetail.do")
        let url = getRequestUrl(body: "/sys/wareHouseReq/app/getPaymentFinishSaveItem.do")
        apiManager.request(api: .getOrderDetail, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: ์ง ์ฌ์ง ์กฐํ
    /// ์ง ์ฌ์ง ์กฐํ
    func getLuggagePictures(userSeq: String, attachType: String, attachGrpSeq: String, orderSeq: String, completion: ResponseJson = nil) {
        // -------------------------- Request -------------------------- //
        //
        //      ORDER_SEQ               ๊ฒฐ์  ์ํ์ค
        //      ATTACH_TYPE             ํ์ผ ํ์
        //      ORDER_ATTACH_GRP_SEQ    ์ฒจ๋ถํ์ผ ๊ทธ๋ฃน ์ํ์ค
        //
        // ------------------------------------------------------------- //
        //
        //
        //
        // -------------------------- Response ------------------------- //
        //
        //      [orderPicList]
        //      ORDER_ATTACH_SEQ        ์ฒจ๋ถ ํ์ผ ์ํ์ค
        //      ORDER_ATTACH_GRP_SEQ    ์ฒจ๋ถ ํ์ผ ๊ทธ๋ฃน ์ํ์ค
        //      ORDER_ATTACH_INFO       ์ง์ฌ์ง url
        //      resCd                   ๊ฒฐ๊ณผ ์ฝ๋
        //
        // ------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ_BUYER": userSeq,
            "ATTACH_TYPE": attachType,
            "ORDER_ATTACH_GRP_SEQ": attachGrpSeq,
            "ORDER_SEQ": orderSeq
        ]
        
        let url = getRequestUrl(body: "/sys/payment/app/getOrderPicList.do")
        apiManager.request(api: .getOrderPictures, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    
    // MARK: ์๋ขฐ ์ํ ๋ณ๊ฒฝ
    /// ์๋ขฐ ์ํ ๋ณ๊ฒฝ
    func updateOrderStatus(orderSeq: String, orderStatus: String, storageSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //       USER_SEQ_BUYER      ์ฌ์ฉ์ ์ํ์ค
        //       ORDER_SEQ           ๊ฒฐ์  ์ํ์ค
        //       ORDER_STATUS        ์ด์ก์ฌ์์ ๋ช     (๋งก๊ธธ๋ 006, ์ฐพ์๋ 008 ๋ณด๋ด๋ฉด๋จ)
        //                                          002 : ๊ฒฐ์  ์๋ฃ(์ต์ด์ํ)
        //                                          006 : ์ฌ์ฉ์๊ฐ ์ง์ ๋งก๊ธฐ๊ณ  ๋ํ ์ฒ๋ฆฌ ์ํ
        //                                          004 : ์ด์ก์ฌ์์๊ฐ ์ง์ ๋ฐ์ ๋ฐฐ์ก์ค์ธ ์ํ
        //                                          005 : ์ด์ก์ฌ์์๊ฐ ์ง์ ๋ฐฐ์ก ์๋ฃํ ์ํ
        //                                          008 : ์ฌ์ฉ์๊ฐ ์ง์ ์ฐพ์ ์๋ฌด๊ฐ ์ข๋ฃ๋ ์ํ
        //                                          003 : ์ฃผ๋ฌธ์ด ์ทจ์๋ ์ํ
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ_BUYER": _user.seq,
            "ORDER_SEQ": orderSeq,
            "ORDER_STATUS": orderStatus,
            "ENTRUST_BASE_SEQ": storageSeq
        ]
        
        let url = getRequestUrl(body: "/sys/payment/app/setChangePaymentProcess.do")
        apiManager.request(api: .updateOrderStatus, url: url, headers: headers, parameters: param, completion: completion)
    }
}

