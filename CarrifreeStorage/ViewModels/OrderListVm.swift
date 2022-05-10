//
//  OrderListVm.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/10.
//

import Foundation
import SwiftyJSON

@objc protocol OrderListVmDelegate {
    @objc optional func ready()
}

class OrderListVm {
    
    var delegate: OrderListVmDelegate?
    
    var orders: [OrderData] = []            // 모든 주문 데이터
    var tempOrders: [OrderData] = []        // 새 페이지의 주문 데이터
    var ordersPage: Int = 0                 // 페이지
    var ordersTotalCount: Int = 0           // 의뢰의 총 개수
    
    var currentCategory: String = ""        // 의뢰 종류 (OrderCategory)
    var currentOrderStatus: String = ""     // 의뢰 진행 상황 (OrderStatus)
    
    init(delegate: OrderListVmDelegate) {
        self.delegate = delegate
        
        DispatchQueue.main.async {
            self.delegate?.ready?()
        }
    }
    
    func setDummyDatas() {
        let dummyImages = ["https://ext.fmkorea.com/files/attach/new/20201114/2978469841/2936687197/3199399559/99b983892094b5c6d2fc3736e15da7d1.jpeg",
                           "https://i.pinimg.com/474x/cf/1d/e8/cf1de8648cdfd85ef5ae35061bc61f0b.jpg",
                           "https://pbs.twimg.com/media/D4uU-sCUcAA6doH.jpg",
                           "https://pbs.twimg.com/media/Df6Sc5sVMAA0c-7.jpg"
        ]
        
        
        tempOrders.removeAll()
        for i in 0 ..< 5 {
            let randomIndex = Int.random(in: 0 ..< dummyImages.count)
            let data = OrderData(category: "01", orderSeq: "\(i)\(i)", orderStatus: OrderStatus.entrust.rawValue, name: "user0\(i + 1)", orderDate: "2021-11-11 12:30", during: "5", attachInfo: dummyImages[randomIndex], orderNo: "1208937419", luggages: 1)
            orders.append(data)
            tempOrders.append(data)
        }
    }
    
    func reset() {
        tempOrders.removeAll()
        orders.removeAll()
        ordersPage = 0
        ordersTotalCount = 0
    }
    
    // MARK: 보관/위수탁 의뢰 목록 요청
    /// 보관/위수탁 의뢰 목록 요청
    func getOrders(orderCategory: String, orderStatus: String, orderNo: String = "", orderName: String = "", refresh: Bool = true, completion: ResponseString = nil)
    {
        if currentCategory != orderCategory || currentOrderStatus != orderStatus { reset() }
        else if refresh { reset() }
        currentCategory = orderCategory
        currentOrderStatus = orderStatus
        
        if ordersPage > ordersTotalCount && ordersTotalCount == 0 { return }
        
        let lastOrderRow = orders.last?.row ?? 0
        if ordersTotalCount > 0 && orders.last?.row == ordersTotalCount {
            _log.log("더 이상 불러올 정보가 없습니다.\n\n last row: \(lastOrderRow)\n total: \(ordersTotalCount)\n page: \(ordersPage)")
            return
        } else {
            ordersPage += 1
        }
        
        _log.log("현재 요청 정보\n\n last row: \(lastOrderRow)\n total: \(ordersTotalCount)\n page: \(ordersPage)")
        
        _cas.order.getOrders(orderCategory: orderCategory, orderStatus: orderStatus, page: ordersPage, orderNo: orderNo, orderName: orderName) { (success, json) in
            var msg = ""
            if let json = json, true == success {
                self.tempOrders.removeAll()
                
                //      [payFinishSaveList]
                //      REAL_STORE_TIME         <Number>        실제 보관 시간(분)
                //      ORDER_DATE              <String>        요청 일자(월-일 시:분)
                //      PAY_STATUS              <String>        결제 상태
                //      ATTACH_GRP_SEQ          <Number>        첨부 파일 그룹 시퀀스
                //      ENTRUST_BASE_SEQ        <Number>        보관사업자 시퀀스
                //      MAJOR_ATTACH_INFO       <String>        첨부 파일 정보
                //      EXPECT_STORE_TIME       <Number>        예약 보관 시간(분)
                //      ENTRUST_ADDR            <String>        보관소 주소
                //      PROCESS_DATE            <String>        PROCESS_DATE
                //      DELIVERY_NO             <String>        주문 번호
                //      ORDER_SEQ               <Number>        주문 번호 시퀀스
                //      ORDER_STATUS            <String>        주문 상태
                //      ORDER_KIND              <String>        주문 종류
                //      BOX_CNT                 <Number>        박스 수량(주문 건수)
                //      BUYER_NAME              <String>        고객 이름
                //
                //      (payFinishSaveItemCnt)
                //      BEFORE_CNT              <Number>        보관 예정
                //      ING_CNT                 <Number>        보관 중
                //      FINISH_CNT              <Number>        보관 완료
                //      resCd                   <String>        결과 코드
                
                let arr = json["payFinishSaveList"].arrayValue
                for value in arr {
                    let orderDate = value["ORDER_DATE"].stringValue
//                    let  = ["PAY_STATUS"].stringValue
//                    let attachGrpSeq = value["ATTACH_GRP_SEQ"].stringValue
//                    let storageSeq = value["ENTRUST_BASE_SEQ"].stringValue
//                    let addres = value["ENTRUST_ADDR"].stringValue
//                    let  = ["PROCESS_DATE"].stringValue
                    let attachInfo = value["MAJOR_ATTACH_INFO"].stringValue
                    let orderNo = value["DELIVERY_NO"].stringValue
                    let orderSeq = value["ORDER_SEQ"].stringValue
                    let orderStatus = value["ORDER_STATUS"].stringValue
                    let luggages = value["BOX_CNT"].intValue
                    let name = value["BUYER_NAME"].stringValue
                    let orderCase = value["ORDER_KIND"].stringValue
                    let orderCaseName = OrderCase.getCase(type: orderCase).name
                    
                    var during: Int = 1
                    let status = OrderStatus(rawValue: orderStatus)
                    if status == .take {
                        during = value["REAL_STORE_TIME"].intValue / 60
                    } else {
                        during = value["EXPECT_STORE_TIME"].intValue / 60
                    }
                    
                    let order = OrderData(category: orderCaseName,
                                          orderSeq: orderSeq,
                                          orderStatus: orderStatus,
                                          name: name,
                                          orderDate: orderDate,
                                          during: "\(during)",
                                          attachInfo: attachInfo,
                                          orderNo: orderNo,
                                          luggages: luggages)
                    self.orders.append(order)
                    self.tempOrders.append(order)
                }
                
                
                /*
                let arr = json["saverOrderInfoList"].arrayValue
                for value in arr {
                    let orderSeq = value["ORDER_SEQ"].stringValue
                    let name = value["USER_NAME"].stringValue
                    let orderDate = value["ORDER_DATE"].stringValue
                    
                    let attachInfo = value["MAJOR_ATTACH_INFO"].stringValue
                    let orderStatusTxt = value["STATUS_TEXT"].stringValue
                    let orderStatus = value["ORDER_STATUS"].stringValue
                    let orderNo = value["DELIVERY_NO"].stringValue
                    let luggages = value["BOX_CNT"].intValue
                    let orderCase = value["ORDER_KIND"].stringValue
                    let orderCaseName = OrderCase.getCase(type: orderCase).name
                    
//                    let during = value["ING_DATE"].intValue / 60
                    var during: Int = 1
                    let status = OrderStatus(rawValue: orderStatus)
                    if status == .take {
                        during = json["saverOrderDetail"]["REAL_STORE_TIME"].intValue / 60
                    } else {
                        during = json["saverOrderDetail"]["EXPECT_STORE_TIME"].intValue / 60
                    }
                    
                    let order = OrderData(category: orderCaseName, orderSeq: orderSeq, orderStatus: orderStatus, orderStatusTxt: orderStatusTxt, name: name, orderDate: orderDate, during: "\(during)", attachInfo: attachInfo, orderNo: orderNo, luggages: luggages)
                    self.orders.append(order)
                    self.tempOrders.append(order)
                }
                */
                
                self.ordersTotalCount = json["totalCnt"].intValue
                
            } else {
                msg = "\(_strings[.alertLoadOrdersFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
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

