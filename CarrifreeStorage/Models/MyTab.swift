//
//  MyTabs.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/09.
//

import Foundation

enum MyTab: Int, CaseIterable {
    case home = 0
    case waiting
    case ongoing
    case done
    case cashup
    
    var title: String {
        switch self {
        case .home: return "홈"
        case .waiting: return "주문대기"
        case .ongoing: return "보관중"
        case .done: return "처리완료"
        case .cashup: return "정산"
        }
    }
    
    var desc: String {
        switch self {
        case .home: return ""
        case .waiting: return "보관이 진행되면 ‘보관중’으로 넘어갑니다.\n완료 또는 취소된 보관 내용은 ‘처리완료’로 넘어갑니다."
        case .ongoing: return "보관이 완료되면 ‘처리완료’로 넘어갑니다.\n초과 발생 금액은 직접 정산하시기 바랍니다."
        case .done: return "처리가 완료된 내역을 표시합니다."
        case .cashup: return "보관사업으로 발생한 매출금액과\n지급된 정산금액 내역을 확인합니다."
        }
    }
    
    var normalIcon: String {
        switch self {
        case .home: return "icon-tabbar-0"
        case .waiting: return "icon-tabbar-1"
        case .ongoing: return "icon-tabbar-2"
        case .done: return "icon-tabbar-3"
        case .cashup: return "icon-tabbar-4"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .home: return "icon-tabbar-selected-0"
        case .waiting: return "icon-tabbar-selected-1"
        case .ongoing: return "icon-tabbar-selected-2"
        case .done: return "icon-tabbar-selected-3"
        case .cashup: return "icon-tabbar-selected-4"
        }
    }
    
    var status: String {
        switch self {
        case .waiting: return "002"         // OrderStatus 참고
        case .ongoing: return "006"         // OrderStatus 참고
        case .done: return "008"            // OrderStatus 참고
        default: return ""
        }
    }
}
