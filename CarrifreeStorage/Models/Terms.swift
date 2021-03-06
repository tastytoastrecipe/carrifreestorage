//
//  Terms.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/26.
//
//
//  π¬ Terms
//  μ½κ΄ λ°μ΄ν°
//

import Foundation

struct TermData {
    let seq: String
    let title: String
    let content: String
    let required: Bool          // true=νμ / false=μ ν
}

enum TermCase: Int, CaseIterable {
    case appUse = 0             // μ΄μ©μ½κ΄
    case privateInfo            // κ°μΈμ λ³΄ μ²λ¦¬ λ°©μΉ¨
    case privateInfoCommision   // κ°μΈμ λ³΄μ²λ¦¬ μν λμ
    case localeInfo             // μμΉκΈ°λ°μλΉμ€ μ΄μ©μ½κ΄
    case ad                     // κ΄κ³ μ± μ λ³΄ μμ  λμ
    
    // νμ/μ ν μ¬ν­
    var required: Bool {
        switch self {
        case .ad: return false
        default: return true
        }
    }
    
    // νμ
    var type: String {
        switch self {
        case .appUse: return "001"
        case .privateInfo: return "002"
        case .privateInfoCommision: return "003"
        case .localeInfo: return "004"
        case .ad: return "005"
        }
    }
}


