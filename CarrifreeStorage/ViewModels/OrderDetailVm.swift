//
//  OrderDetailVm.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/15.
//

import Foundation
import UIKit
import SwiftyJSON


@objc protocol OrderDetailVmDelegate {
    @objc optional func ready()
}

class OrderDetailVm {
    
    var delegate: OrderDetailVmDelegate?
    var data: OrderDetailData!
    var orderSeq: String = ""
    
    init(delegate: OrderDetailVmDelegate, orderSeq: String) {
        self.delegate = delegate
        self.orderSeq = orderSeq
        
        // 서버에서 데이터 받아온 후 각 변수 초기화
        getOrderDetail(orderSeq: orderSeq) { (success, msg) in
            if success {
                self.delegate?.ready?()
            } else {
                _log.log(msg)
            }
        }
    }
    
    // MARK: 의뢰 상세 정보 요청
    /// 의뢰 상세 정보 요청
    func getOrderDetail(orderSeq: String, completion: ResponseString = nil) {
        _cas.order.getOrderDetail(orderSeq: orderSeq) { (success, json) in
            var msg = ""
            if let json = json, success {
                //      (payFinishSaveItem)
                //      REAL_STORE_TIME         <Number>        실제 보관 시간(분)
                //      ORDER_ATTACH_GRP_SEQ    <Number>        짐 사진 그룹 시퀀스
                //      ENTRUST_BASE_SEQ        <Number>        보관사업자 시퀀스
                //      USER_EMAIL              <String>        이메일
                //      TAKE_DATE               <String>        찾은 날짜(예약)
                //      ENTRUST_DATE            <String>        맡긴 날짜(예약)
                //      XL_TYPE                 <Number>        대형짐
                //      OVER_AMOUNT             <Number>        추가 요금
                //      ING_DATE                <String>        맡긴 날짜(실제)
                //      FINISH_DATE             <String>        찾은 날짜(실제)
                //      ORDER_STATUS            <String>        주문 상태
                //      L_TYPE                  <Number>        큰짐
                //      USER_HP_NO              <String>        연락처
                //      S_TYPE                  <Number>        미니짐
                //      ORDER_KIND_TEXT         <String>        주문 종류
                //      ORDER_DATE              <String>        주문 날짜
                //      EXPECT_STORE_TIME       <Number>        예약 시간(분)
                //      M_TYPE                  <Number>        중간짐
                //      BUYER_MEMO              <String>        요청 사항
                //      PAY_AMOUNT              <Number>        결제 금액
                //      DELIVERY_NO             <String>        주문 번호
                //      ORDER_SEQ               <Number>        주문 번호 시퀀스
                //      ORDER_KIND              <String>        주문 종류
                //      BUYER_NAME              <String>        이름
                //      USER_SEQ_BUYER          <Number>        주문의뢰자 시퀀스
                //      TOTAL_AMOUNT            <Number>        총 금액
                //
                //                                                          [boxList]
                //                                                          ITEM_QUANTITY   <Number>    짐 갯수
                //                                                          ITEM_KIND       <String>    짐 종류 코드
                //                                                          ITEM_KIND_TXT   <String>    짐 종류
                
                let val = json["payFinishSaveItem"]
                
                let attachGrpSeq = val["ORDER_ATTACH_GRP_SEQ"].stringValue
                let email = val["USER_EMAIL"].stringValue
                let orderStatus = val["ORDER_STATUS"].stringValue
                let phone = val["USER_HP_NO"].stringValue
                let orderCategory = val["ORDER_KIND_TEXT"].stringValue
                let orderDate = val["ORDER_DATE"].stringValue
                let comment = val["BUYER_MEMO"].stringValue
                
                let orderNo = val["DELIVERY_NO"].stringValue
                let orderSeq = val["ORDER_SEQ"].stringValue

                let name = val["BUYER_NAME"].stringValue
                let userSeq = val["USER_SEQ_BUYER"].stringValue
                
                let extraCost = val["OVER_AMOUNT"].stringValue
                let cost = val["PAY_AMOUNT"].stringValue
                let totalCost = val["TOTAL_AMOUNT"].stringValue
                
                let s = val["S_TYPE"].intValue
                let m = val["M_TYPE"].intValue
                let l = val["L_TYPE"].intValue
                let xl = val["XL_TYPE"].intValue
                
                var startTime = val["ENTRUST_DATE"].stringValue
                let inStartTime = val["ING_DATE"].stringValue
                if false == inStartTime.isEmpty { startTime = inStartTime }
                
                var endTime = val["TAKE_DATE"].stringValue
                let inEndTime = val["FINISH_DATE"].stringValue
                if false == inEndTime.isEmpty { endTime = inEndTime }
                
                let storageSeq = val["ENTRUST_BASE_SEQ"].stringValue
                //                let orderCase = val["ORDER_KIND"].stringValue
                
                var during: Int = 1
                let status = OrderStatus(rawValue: orderStatus)
                if status == .take {
                    during = val["REAL_STORE_TIME"].intValue
                } else {
                    during = val["EXPECT_STORE_TIME"].intValue
                }
                
                self.data = OrderDetailData(category: orderCategory,
                                            orderSeq: orderSeq,
                                            orderStatus: orderStatus,
                                            orderStatusTxt: "",
                                            name: name,
                                            orderDate: orderDate,
                                            during: during,
                                            attachGrpSeq: attachGrpSeq,
                                            orderNo: orderNo,
                                            row: 0,
                                            s: s,
                                            m: m,
                                            l: l,
                                            xl: xl,
                                            cost: cost,
                                            extraCost: extraCost,
                                            totalCost: totalCost,
                                            phone: phone,
                                            comment: comment,
                                            startTime: startTime,
                                            endTime: endTime,
                                            imgs: [],
                                            email: email,
                                            userSeq: userSeq)
                self.data.storageSeq = storageSeq
                
            }
            else {
                msg = "\(_strings[.alertLoadOrderFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
                let failedMsg = self.getFailedMsg(json: json)
                if failedMsg.count > 0 { msg += "\n\(failedMsg)" }
            }
            
            
            
            
            
            
            /*
            if let json = json, success {
                
                let s = json["saverOrderDetail"]["S_TYPE"].intValue
                let m = json["saverOrderDetail"]["M_TYPE"].intValue
                let l = json["saverOrderDetail"]["L_TYPE"].intValue
                let xl = json["saverOrderDetail"]["XL_TYPE"].intValue
                
                let orderCategory = json["saverOrderDetail"]["ORDER_KIND_TEXT"].stringValue
                let attachGrpSeq = json["saverOrderDetail"]["ORDER_ATTACH_GRP_SEQ"].stringValue
                let orderDate = json["saverOrderDetail"]["ORDER_DATE"].stringValue
                let email = json["saverOrderDetail"]["USER_EMAIL"].stringValue
                let startTime = json["saverOrderDetail"]["ENTRUST_DATE"].stringValue
                let endTime = json["saverOrderDetail"]["TAKE_DATE"].stringValue
                let name = json["saverOrderDetail"]["USER_NAME"].stringValue
                let comment = json["saverOrderDetail"]["BUYER_MEMO"].stringValue
                let orderNo = json["saverOrderDetail"]["DELIVERY_NO"].stringValue
                let orderSeq = json["saverOrderDetail"]["ORDER_SEQ"].stringValue
                let phone = json["saverOrderDetail"]["USER_HP_NO"].stringValue
                let orderStatus = json["saverOrderDetail"]["ORDER_STATUS"].stringValue
                let cost = json["saverOrderDetail"]["TOTAL_AMOUNT"].stringValue
                let userSeq = json["saverOrderDetail"]["USER_SEQ_BUYER"].stringValue
//                let  = json["saverOrderDetail"]["ORDER_KIND"].stringValue
//                let storageSeq = json["saverOrderDetail"]["ENTRUST_BASE_SEQ"].stringValue
                
                var during: Int = 1
                let status = OrderStatus(rawValue: orderStatus)
                if status == .take {
                    during = json["saverOrderDetail"]["REAL_STORE_TIME"].intValue
                } else {
                    during = json["saverOrderDetail"]["EXPECT_STORE_TIME"].intValue
                }
                
                self.data = OrderDetailData(category: orderCategory, orderSeq: orderSeq, orderStatus: orderStatus, orderStatusTxt: "", name: name, orderDate: orderDate, during: during, attachGrpSeq: attachGrpSeq, orderNo: orderNo, row: 0, s: s, m: m, l: l, xl: xl, cost: cost, phone: phone, comment: comment, startTime: startTime, endTime: endTime, imgs: [], email: email, userSeq: userSeq)
                
            } else {
                msg = "\(_strings[.alertLoadOrderFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
                let failedMsg = self.getFailedMsg(json: json)
                if failedMsg.count > 0 { msg += "\n\(failedMsg)" }
            }
            */
            
            completion?(success, msg)
        }
    }
    
    // MARK: 의뢰 물품 사진 요청
    /// 의뢰 물품 사진 요청
    func getOrderPictures(completion: ResponseString = nil) {
        if nil == data {
            completion?(false, _strings[.alertEmptyOrder])
            return
        }
        
        _cas.order.getLuggagePictures(userSeq: _user.seq, attachType: AttachType.luggage.rawValue, attachGrpSeq: data.attachGrpSeq, orderSeq: data.orderSeq) { (success, json) in
            var msg = ""
            if let json = json, success {
                let arr = json["orderPicList"].arrayValue
                for value in arr {
                    let url = value["ORDER_ATTACH_INFO"].stringValue
                    self.data.imgs.append(url)
                }
                
            } else {
                msg = "\(_strings[.alertLoadLuggagePicFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
                let failedMsg = self.getFailedMsg(json: json)
                if failedMsg.count > 0 { msg += "\n\(failedMsg)" }
            }
        
            completion?(success, msg)
        }
    }
    
    // MARK: 의뢰 상태 변경
    /// 의뢰 상태 변경
    func updateOrderStatus(orderStatus: String, completion: ResponseString = nil) {
        if nil == data {
            completion?(false, _strings[.alertEmptyOrder])
            return
        }
        
        _cas.order.updateOrderStatus(orderSeq: data.orderSeq, orderStatus: orderStatus, storageSeq: data.storageSeq) { (success, json) in
            var msg = ""
            if success {
                self.data.orderStatus = orderStatus
            } else {
                msg = "\(_strings[.alertOrderUpdateFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
                let failedMsg = self.getFailedMsg(json: json)
                if failedMsg.count > 0 { msg += "\n\(failedMsg)" }
            }
            
            completion?(success, msg)
        }
    }
    
    func getFailedMsg(json: JSON?) -> String {
        guard let json = json else { return "" }
        var message = json["resMsg"].stringValue
        if message.isEmpty { message = _strings[.requestFailed] }
        return message
    }
}


