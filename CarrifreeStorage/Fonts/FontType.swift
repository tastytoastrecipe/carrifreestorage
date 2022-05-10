//
//  FontType.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/01.
//

import UIKit

// 폰트 구분  (삭제 예정)
let titleFont = UIFont(name: "NanumSquareR", size: 20)
let subTitleFont = UIFont(name: "NanumSquareR", size: 17)
let fieldFont = UIFont(name: "NanumSquareR", size: 15)
let descFont01 = UIFont(name: "NanumSquareR", size: 13)
let descFont02 = UIFont(name: "NanumSquareR", size: 12)

let titleFontBold = UIFont(name: "NanumSquareB", size: 20)
let subTitleFontBold = UIFont(name: "NanumSquareB", size: 17)
let fieldFontBold = UIFont(name: "NanumSquareB", size: 15)
let descFont01Bold = UIFont(name: "NanumSquareB", size: 13)
let descFont02Bold = UIFont(name: "NanumSquareB", size: 12)

// 폰트 구분 enum
enum BoldCase {
    case regular
    case bold
    case extraBold
    
    var name: String {
        switch self {
        case .regular: return "NanumSquareR"
        case .bold: return "NanumSquareB"
        case .extraBold: return "NanumSquareEB"
        }
    }
}
