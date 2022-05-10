//
//  CarrifreeAppType.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/31.
//

import Foundation

enum CarrifreeAppType: String {
    case appUser        = "I001"        // 사용자앱
    case appStorage     = "I002"        // 보관사업자앱
    case appDelivery    = "I003"        // 운반사업자앱
    
    var user: String {
        switch self {
        case .appUser: return "001"
        case .appStorage: return "002"
        case .appDelivery: return "003"
        }
    }
}
