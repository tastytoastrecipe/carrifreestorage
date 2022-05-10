//
//  Order.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/10.
//

import Foundation

// MARK: - OrderData
struct OrderData: OrderBase {
    var category: String
    
    var orderSeq: String
    
    var orderStatus: String
    
    var name: String
    
    var orderDate: String
    
    var during: String          
    
    var attachInfo: String
    
    var orderNo: String
    
    var luggages: Int
    
    var row: Int = 0
    
}

// MARK: - OrderDetailData
struct OrderDetailData: OrderDetail, Luggages {
    var category: String
    
    var orderSeq: String
    
    var orderStatus: String
    
    var orderStatusTxt: String
    
    var name: String
    
    var orderDate: String
    
    var during: Int
    
    var attachGrpSeq: String
    
    var orderNo: String
    
    var row: Int
    
    var s: Int
    
    var m: Int
    
    var l: Int
    
    var xl: Int
    
    var cost: String
    
    var extraCost: String
    
    var totalCost: String
    
    var phone: String
    
    var comment: String
    
    var startTime: String
    
    var endTime: String
    
    var imgs: [String]
    
    var email: String
    
    var userSeq: String
    
    var storageSeq: String = ""
}

// MARK: - OrderBase
protocol OrderBase {
    var orderSeq: String { get set }                    // 주문 시퀀스
    var category: String { get set }                    // 주문 종류 (OrderCategory)
    var orderNo: String { get set }                     // 주문 번호
}

// MARK: - OrderNormal
protocol OrderNormal: OrderBase {
    var orderStatus: String { get set }                 // 현재 의뢰 상태 (OrderStatus)
    var orderStatusTxt: String { get set }              // 현재 의뢰 상태 (유저에게 보여질 문구)
    var name: String { get set }
    var orderDate: String { get set }
    var during: Int { get set }
    var attachGrpSeq: String { get set }
    var row: Int { get set }
}

// MARK: - OrderDetail
protocol OrderDetail: OrderNormal {
    var cost: String { get set }
    var extraCost: String { get set }
    var totalCost: String { get set }
    var phone: String { get set }
    var comment: String { get set }
    var startTime: String { get set }
    var endTime: String { get set }
    var imgs: [String] { get set }
    var email: String { get set }
    var userSeq: String { get set }     // 유저(고객) 시퀀스
}


// MARK: - 의뢰 진행 상황
enum OrderStatus: String {
                                // (맡길때 006, 찾을때 008 보내면됨)
    case purchased =  "002"     // 002: 결제 완료(최초상태)
    case entrust   =  "006"     // 006: 사용자가 짐을 맡기고 난후 처리 상태
    case delivery  =  "004"     // 004: 운송사업자가 짐을 받아 배송중인 상태
    case arrive    =  "005"     // 005: 운송사업자가 짐을 배송 완료한 상태
    case take      =  "008"     // 008: 사용자가 짐을 찾아 업무가 종료된 상태
    case auth      =  "007"     // 007: 운송사업자든 일반사용자든 짐을 찾기 위해 인증하는 상태 (비밀번호를 넣어 물건 찾을 사람을 인증 한 상태)
    case canceled  =  "003"     // 003: 주문이 취소된 상태
    
    var orderTitle: String {
        switch self {
        case .purchased: return _strings[.orderStatusPurchasedTitle]
        case .entrust: return _strings[.orderStatusEntrustTitle]
        case .take: return _strings[.orderStatusTakeTitle]
        default: return ""
        }
    }
    
    var orderDesc: String {
        switch self {
        case .purchased: return _strings[.orderStatusPurchasedDesc]
        case .entrust: return _strings[.orderStatusEntrustDesc]
        case .take: return _strings[.orderStatusTakeDesc]
        default: return ""
        }
    }
}

// MARK: - 의뢰 종류
enum OrderCategory: String {
    case all        = "00"      // 모든 의뢰
    case storage    = "01"      // 보관 의뢰
    case keep       = "02"      // 위수탁 의뢰
    
    var name: String {
        switch self {
        case .all: return "전체"
        case .storage: return "보관"
        case .keep: return "위수탁"
        }
    }
}

// MARK: - 의뢰 종류
@objc enum OrderCase: Int {
    case none = 0
    case storage            // 보관
    case carry              // 운반
    
    case reservation        // 예약
    case realtime           // 실시간
    case estimate           // 가격 요청
    case waitingRealtime    // 대기중인 실시간 요청
    case waitingEstimate    // 대기중인 견적 요청
    case direct             // 직영 운반사업자
    
    var name: String {
        switch self {
        case .storage: return "보관"
        case .carry: return "운반"
        default: return ""
        }
    }
    
    var type: String {
        switch self {
        case .realtime, .waitingRealtime: return "001"
        case .reservation:                return "002"
        case .estimate, .waitingEstimate: return "003"
        case .storage:                    return "004"
        case .direct:                     return "005"
        default:                          return ""
        }
    }
    
    static func getCase(type: String) -> OrderCase {
        switch type {
        case OrderCase.storage.type: return OrderCase.storage
        case OrderCase.carry.type: return OrderCase.carry
        default: return OrderCase.none
        }
    }
    
    static func getType(orderCase: Int) -> String {
        switch orderCase {
        case OrderCase.storage.rawValue: return OrderCase.storage.type
        case OrderCase.carry.rawValue: return OrderCase.carry.type
        default: return OrderCase.none.type
        }
    }
}

// MARK: - 보관 방식 분류
enum StorageType: String {
    case noBase     = "001"      // 출발지점, 도착지점 모두 캐리어 베이스 아님
    case all        = "002"      // 출발지점, 도착지점 모두 캐리어 베이스
    case startBase  = "003"      // 출발지점만 캐리어 베이스
    case endBase    = "004"      // 도착지점만 캐리어 베이스
}

// MARK: - Luggages
protocol Luggages {
    var s: Int { get set }
    var m: Int { get set }
    var l: Int { get set }
    var xl: Int { get set }
}

extension Luggages {
    mutating func setLuggages(s: Int, m: Int, l: Int, xl: Int) {
        self.s = s; self.m = m; self.l = l; self.xl = xl
    }
    
    func getLuggageCount() -> Int {
        return s + m + l + xl
    }
    
    func getLuggageString() -> String {
        var luggageString = ""
        
        if s > 0 {
            luggageString = "\(LuggageType.s.luggageName) \(s)"
        }
        
        if m > 0 {
            if luggageString.isEmpty{
                luggageString = "\(LuggageType.m.luggageName) \(m)"
            } else {
                luggageString = "\(luggageString), \(LuggageType.m.luggageName) \(m)"
            }
        }
        
        if l > 0 {
            if luggageString.isEmpty{
                luggageString = "\(LuggageType.l.luggageName) \(l)"
            } else {
                luggageString = "\(luggageString), \(LuggageType.l.luggageName) \(l)"
            }
            
        }
        
        if xl > 0 {
            if luggageString.isEmpty{
                luggageString = "\(LuggageType.xl.luggageName) \(xl)"
            } else {
                luggageString = "\(luggageString), \(LuggageType.xl.luggageName) \(xl)"
            }
            
        }
        
        return luggageString
    }
    
    func getLuggageSymbolString() -> String {
        var luggageString = ""
        
        if s > 0 {
            luggageString = "(\(LuggageType.s.name)) \(s)건"
        }
        
        if m > 0 {
            if luggageString.isEmpty{
                luggageString = "(\(LuggageType.m.name)) \(m)건"
            } else {
                luggageString = "\(luggageString), (\(LuggageType.m.name)) \(m)건"
            }
        }
        
        if l > 0 {
            if luggageString.isEmpty{
                luggageString = "(\(LuggageType.l.name)) \(l)건"
            } else {
                luggageString = "\(luggageString), (\(LuggageType.l.name)) \(l)건"
            }
            
        }
        
        if xl > 0 {
            if luggageString.isEmpty{
                luggageString = "(\(LuggageType.xl.name)) \(xl)건"
            } else {
                luggageString = "\(luggageString), (\(LuggageType.xl.name)) \(xl)건"
            }
            
        }
        
        return luggageString
    }
}
