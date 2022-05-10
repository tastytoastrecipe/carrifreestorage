//
//  CashupVm.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/18.
//

import Foundation
import SwiftyJSON

class CashupVm {
    
    var data: MonthlySales!
    
    var currentMonth: Int = 0
    var currentYear: Int = 0
    
    init() {
        let now = Date().localDate
        currentYear = now.get(.year)
        currentMonth = now.get(.month) - 1
        data = MonthlySales()
    }
    
    /// 정산 정보 요청
    func getMonthlySales(month: String, completion: ResponseString = nil) {
        self.data.reset()
        _cas.cashup.getMonthlySales(month: month) { (success, json) in
            var msg = ""
            if let json = json, success {
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
                
                let salesStr = json["getTotMonthSaleItem"]["USER_FEE"].stringValue
                let cashupStr = json["getTotMonthSaleItem"]["PAYBACK_USER_FEE"].stringValue
                let sales = _utils.getIntFromDelimiter(str: salesStr)
                let cashup = _utils.getIntFromDelimiter(str: cashupStr)
                self.data.sales = sales
                self.data.cashup = cashup
                
                let annualSales = json["getMonthSaleList"].arrayValue
                for monthlySale in annualSales {
                    let entrustSalesStr = monthlySale["ENTRUST_FEE"].stringValue
                    let entrustSales = _utils.getIntFromDelimiter(str: entrustSalesStr)
                    let takeSalesStr = monthlySale["TAKE_FEE"].stringValue
                    let takeSales = _utils.getIntFromDelimiter(str: takeSalesStr)
                    let sales = entrustSales + takeSales
                    let name = monthlySale["USER_NAME"].stringValue
                    let dayText = monthlySale["DAY_TEXT"].stringValue
                    let timestamp = (TimeInterval(dayText) ?? 0) / 1000
                    let day = Date(timeIntervalSince1970: timestamp).get(.day)
                    let orderNo = monthlySale["DELIVERY_NO"].stringValue
                    let orderCategory = monthlySale["ORDER_KIND_TEXT"].stringValue
                    let orderSeq = monthlySale["ORDER_SEQ"].stringValue
                    let during = monthlySale["ING_DATE"].intValue
                    let luggageCount = monthlySale["BOX_CNT"].intValue
                    //                    let cashupStr = monthlySale["PAYBACK_USER_FEE"].stringValue
                    //                    let cashup = _utils.getIntFromDelimiter(str: cashupStr)
                    
                    self.data.addSales(orderSeq: orderSeq, category: orderCategory, orderNo: orderNo, name: name, durationHour: during, day: "\(day)", luggageCount: luggageCount, sales: sales)
                }
                
            } else {
                msg = "\(_strings[.alertLoadCashupFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
                let failedMsg = self.getFailedMsg(json: json)
                if failedMsg.count > 0 { msg += "\n\(failedMsg)" }
            }
            
            completion?(success, msg)
        }
        
    }
    
    /// 특정일의 매출 금액 반환
    func getCost(day: String) -> Int {
        var cost: Int = 0
        for sale in data.dailySales {
            guard day == sale.day else { continue }
            cost += sale.sales
        }
        
        return cost
    }
    
    /// 매출이 있는 날인지 여부를 반환
    func isLuckyDay(day: String) -> Bool {
        for sale in data.dailySales {
            if day == sale.day { return true }
        }
        
        return false
    }
    
    /// 특정일의 매출 데이터 반환
    func getDailySales(day: String) -> [DailySales] {
        var datas: [DailySales] = []
        for sale in data.dailySales {
            guard day == sale.day else { continue }
            datas.append(sale)
        }
        
        return datas
    }
    
    func getFailedMsg(json: JSON?) -> String {
        guard let json = json else { return "" }
        var message = json["resMsg"].stringValue
        if message.isEmpty { message = _strings[.requestFailed] }
        return message
    }
}



