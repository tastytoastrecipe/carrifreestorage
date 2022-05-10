//
//  Sales.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/18.
//

import Foundation

// MARK: 매출 항목 데이터
struct DailySales: OrderBase, SalesData {
    var orderSeq: String
    
    var category: String
    
    var orderNo: String
    
    var sales: Int
    
    var name: String
    
    var durationHour: Int
    
    var day: String
    
    var luggageCount: Int
}



// MARK: 정산 항목 데이터
struct Cashups: OrderBase, CashupData {
    var orderSeq: String
    
    var category: String
    
    var orderNo: String
    
    var cashup: Int
    
    var day: String
    
    var durationDate: String
}

// MARK: 매출 + 정산 항목 데이터
struct CashupDetails: OrderBase, SalesData, CashupData {
    var orderSeq: String
    
    var category: String
    
    var orderNo: String
    
    var sales: Int
    
    var name: String
    
    var durationHour: Int
    
    var date: String
    
    var luggageCount: Int
    
    var cashup: Int
    
    var day: String
    
    var durationDate: String
}


// MARK: 월매출 데이터
struct MonthlySales {
    var sales: Int = 0                  // 월 매출
    var cashup: Int = 0                 // 월 정산 금액
    var month: Int = 0
    var dailySales: [DailySales] = []
    
    init() {}
    
    init(sales: Int, cashup: Int, month: Int) {
        self.sales = sales
        self.cashup = cashup
        self.month = month
    }
    
    init(sales: Int, cashup: Int, month: Int, dailySales: [DailySales]) {
        self.sales = sales
        self.cashup = cashup
        self.month = month
        self.dailySales = dailySales
    }
    
    mutating func addSales(orderSeq: String, category: String, orderNo: String, name: String, durationHour: Int, day: String, luggageCount: Int, sales: Int) {
        let sale = DailySales(orderSeq: orderSeq, category: category, orderNo: orderNo, sales: sales, name: name, durationHour: durationHour, day: day, luggageCount: luggageCount)
        dailySales.append(sale)
    }
    
//    mutating func addSales(category: String, day: String, name: String, storageType: String, sales: Int, cashup: Int, orderNo: String) {
//        let sale = DailySales(category: category, sales: sales, cashup: cashup, name: name, storageType: storageType, day: day, orderNo: orderNo)
//        dailySales.append(sale)
//    }
    
    mutating func reset() {
        dailySales.removeAll(); sales = 0; cashup = 0; month = 0
    }
}

// MARK: 매출 데이터
protocol SalesData {
    var sales: Int { get set }              // 매출
    var name: String { get set }            // 고객명
    var durationHour: Int { get set }       // 보관 시간 (n시간)
    var day: String { get set }             // 매출이 발생한 날 (date)
    var luggageCount: Int { get set }       // 짐 개수
}

// MARK: 정산 데이터
protocol CashupData {
    var cashup: Int { get set }             // 정산 금액
    var day: String { get set }             // 매출이 발생한 날 (day)
    var durationDate: String { get set }    // 보관 시간 (시작시간 ~ 완료시간)
}

