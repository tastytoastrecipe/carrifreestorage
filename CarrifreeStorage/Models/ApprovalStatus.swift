//
//  ApprovalStatus.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/20.
//

import Foundation

// MARK: - 승인 상태
enum ApprovalStatus {
    case approved           // 승인됨
    case wating             // 승인 대기중
    case beforeRequest      // 승인 요청도 안함
    case none
}

// MARK: - 메인화면의 탭 정보
struct MainTapInfo {
    
    var approval = ApprovalStatus.none      // 사업자 승인 상태
    var stored: Bool = false                // 매장 정보 등록 여부
    var storage: Int = 0                    // 보관탭 badge에 표시될 숫자
    var cBase: Int = 0                      // 위수탁탭 badge에 표시될 숫자
            
    var providerInfo: Int = 0               // 기본 정보 버튼 badge 표시 여부 (0: 정보 입력이 필요한 상태 / 1 이상: 정보 입력 완료된 상태)
    var storeInfo: Int = 0                  // 보관소 정보 버튼 badge 표시 여부
    var holidayInfo: Int = 0                // 쉬는날 정보 버튼 badge 표시 여부
    var costInfo: Int = 0                   // 보관단가 정보 버튼 badge 표시 여부
            
    var todaySales: Int = 0                 // 오늘 예상 매출
    var monthSales: Int = 0                 // 이번달 예상 매출
            
    var completeAllInfo: Bool {             // 모든 사업자 정보 등록 여부
        get {
            if providerInfo > 0 && storeInfo > 0 && holidayInfo > 0 && costInfo > 0 { return true }
            return false
        }
    }
    
    init() {}
    init(approved: String, stored: String, storage: Int, cBase: Int, providerInfo: Int, storeInfo: Int, holidayInfo: Int, costInfo: Int, todaySales: Int, monthSales: Int) {
        setData(approved: approved, stored: stored, storage: storage, cBase: cBase, providerInfo: providerInfo, storeInfo: storeInfo, holidayInfo: holidayInfo, costInfo: costInfo, todaySales: todaySales, monthSales: monthSales)
    }
    
    mutating func setData(approved: String, stored: String, storage: Int, cBase: Int, providerInfo: Int, storeInfo: Int, holidayInfo: Int, costInfo: Int, todaySales: Int, monthSales: Int) {
        self.storage = storage; self.cBase = cBase; self.providerInfo = providerInfo; self.storeInfo = storeInfo; self.holidayInfo = holidayInfo; self.costInfo = costInfo; self.todaySales = todaySales; self.monthSales = monthSales
        
        if approved == "Y" {
            approval = .approved
        } else if approved == "N" {
            approval = .wating
        } else {
            approval = .beforeRequest
        }
        
        self.stored = (stored == "Y")
    }
    
    mutating func removeData() {
        setData(approved: "", stored: "", storage: 0, cBase: 0, providerInfo: 0, storeInfo: 0, holidayInfo: 0, costInfo: 0, todaySales: 0, monthSales: 0)
    }
}
