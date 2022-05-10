//
//  CostData.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/12/23.
//

import Foundation

class CostData {
    var seq: String = ""
    var type: String = ""
    var section: String = ""
    var price: String = ""
    var defaultPrice: String = ""
    var limitPercent: Float = 0.5   // 50% - 기본값(defaultPrice)을 기준으로 설정할 수 있는 가격의 범위 %
}
