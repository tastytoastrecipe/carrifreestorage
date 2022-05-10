//
//  BizData.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/04.
//

import Foundation
import SwiftyJSON

// 사업자 데이터
struct BizData {
    var bankCode: String
    var bankAccount: String
    var bankName: String
    var licenseNo: String
    var name: String
    var contact: String
    var addr: String
    var addrDetail: String
    var addrCode: String
    var licensePicUrl: String
    var licensePicSeq: String
    var bankbookPicUrl: String
    var bankbookPicSeq: String
    var bizType: String
    var lat: Double
    var lng: Double
    var hidden: Bool
    
    init(json: JSON) {
        bankCode = json["BANK_CD"].stringValue
        bankAccount = json["BANK_PRIVATE_NO"].stringValue
        bankName = json["BANK_NM"].stringValue
        licenseNo = json["BIZ_CORP_NO"].stringValue
        name = json["BIZ_NAME"].stringValue
        contact = json["USER_HP_NO"].stringValue
        addr = json["BIZ_SIMPLE_ADDR"].stringValue
        addrDetail = json["BIZ_DETAIL_ADDR"].stringValue
        addrCode = json["ZIP_CD"].stringValue
        bizType = json["CD_BIZ_TYPE"].stringValue
        lat = json["BIZ_LAT"].doubleValue
        lng = json["BIZ_LNG"].doubleValue
        
        licensePicUrl = json["BIZ_ATTACH_INFO"].stringValue
        licensePicSeq = json["BIZ_ATTACH_SEQ"].stringValue
        if licensePicUrl.contains("no_profile") { licensePicUrl = "" }
        
        bankbookPicUrl = json["BANK_ATTACH_INFO"].stringValue
        bankbookPicSeq = json["BANK_ATTACH_SEQ"].stringValue
        if bankbookPicUrl.contains("no_profile") { bankbookPicUrl = "" }
        
        let visibleStr = json["AVAILABLE_YN"].stringValue
        hidden = !(visibleStr == "Y")
    }
}
