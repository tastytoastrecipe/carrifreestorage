//
//  StoreCategoryData.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/02.
//

import Foundation

// MARK:- 업종 데이터
struct StoreCategoryData {
    var code: String = ""
    var name: String = ""
    
    init() {}
    
    init(code: String, name: String) {
        self.code = code; self.name = name
    }
}

// MARK: - 매장정보의 각 코드 그룹
/// 매장정보의 각 코드 그룹
/// 은행, 업종, 보관장점, 요일 등
enum StorageCodeGroup: String {
    case bank = "001"           // 은행 코드
    case category = "002"       // 업종 코드
    case merit = "003"          // 보관장점 코드
    case weeks = "004"          // 요일 코드
}


// MARK: - 매장정보 코드 데이터
struct StorageCode {
    var grp: String             // 코드 그룹 (StorageCodeGroup)
    var code: String            // 코드
    var name: String            // 이름
}

// MARK: - 보관 시간 타입
/// 보관 시간 타입 (결제지 사용됨)
/// 24시간이 지나면 001, 24시간이 지나지 않으면 002
enum StorageDayType: String {
    case dayOver = "001"        // 24시간이 이상
    case dayIn = "002"          // 24시간 미만
    case none = ""
}
