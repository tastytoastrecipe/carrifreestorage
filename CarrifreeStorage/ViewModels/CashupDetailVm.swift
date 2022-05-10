//
//  CashupDetailVm.swift
//  TestProject
//
//  Created by orca on 2021/11/20.
//

import Foundation
import UIKit
import SwiftyJSON


@objc protocol CashupDetailVmDelegate {
    @objc optional func ready()
}

class CashupDetailVm {
    
    var sales: Int = 0
    var duration: String = ""
    var dailySales: [DailySales] = []
    var delegate: CashupDetailVmDelegate?
    
    init(delegate: CashupDetailVmDelegate) {
        self.delegate = delegate
    }
    
    func setDummyData() {
        sales = 75000
        duration = "2021-11-01 ~ 2021-11-15"
        
        dailySales = [DailySales(orderSeq: "1", category: OrderCategory.storage.rawValue, orderNo: "000000001", sales: 1001, name: "user01", durationHour: 2, day: "01", luggageCount: 2),
                      DailySales(orderSeq: "2", category: OrderCategory.storage.rawValue, orderNo: "000000002", sales: 1001, name: "user01", durationHour: 2, day: "03", luggageCount: 2),
                      DailySales(orderSeq: "3", category: OrderCategory.storage.rawValue, orderNo: "000000003", sales: 1001, name: "user01", durationHour: 2, day: "08", luggageCount: 2),
                      DailySales(orderSeq: "4", category: OrderCategory.storage.rawValue, orderNo: "000000004", sales: 1001, name: "user01", durationHour: 2, day: "09", luggageCount: 2),
                      DailySales(orderSeq: "5", category: OrderCategory.storage.rawValue, orderNo: "000000005", sales: 1001, name: "user01", durationHour: 2, day: "11", luggageCount: 2),
                      DailySales(orderSeq: "6", category: OrderCategory.storage.rawValue, orderNo: "000000006", sales: 1001, name: "user01", durationHour: 2, day: "14", luggageCount: 2),
                      DailySales(orderSeq: "7", category: OrderCategory.storage.rawValue, orderNo: "000000007", sales: 1001, name: "user01", durationHour: 2, day: "15", luggageCount: 2),
                      DailySales(orderSeq: "8", category: OrderCategory.storage.rawValue, orderNo: "000000008", sales: 1001, name: "user01", durationHour: 2, day: "15", luggageCount: 2),
                      DailySales(orderSeq: "9", category: OrderCategory.storage.rawValue, orderNo: "000000009", sales: 1001, name: "user01", durationHour: 2, day: "23", luggageCount: 2)]
    }
    
}

