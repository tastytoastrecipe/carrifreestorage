//
//  PushDatas.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/06/08.
//

import Foundation

class PushDatas {
    
    lazy var requestDetail = PushRequestDetail()
    
    func createPushData(route: CarryPush.PushRoute, parameters: [String]) {
        switch route {
        case .requestDetail:
            if parameters.count > 0 { requestDetail.orderSeq = parameters[0] }
            if parameters.count > 1 { requestDetail.userSeq = parameters[1] }
            
        case .none: break
        }
    }
}


class PushRequestDetail {
    var orderSeq: String = ""
    var userSeq: String = ""
    
    init() {}
    init(orderSeq: String, userSeq: String) {
        self.orderSeq = orderSeq; self.userSeq = userSeq
    }
}
