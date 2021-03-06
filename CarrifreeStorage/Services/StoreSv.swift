//
//  StoreSv.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/11/02.
//
//
//  π¬ ## StoreSv ##
//  π¬ λ§€μ₯ μ λ³΄ λ±λ‘/μμ  κ΄λ ¨ API λͺ¨μ
//

import Foundation

import Alamofire
import SwiftyJSON 

class StoreSv: Service {
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    // MARK: - λ§€μ₯ μ λ³΄ μ‘°ν
    /// λ§€μ₯ μ λ³΄ μ‘°ν
    func getStoreInfo(completion: ResponseJson = nil) {
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/getWayInfo.do")
        apiManager.request(api: .getStoreInfo, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - μμμκ° μ‘°ν
    /// μμμκ° μ‘°ν
    func getWorkTime(completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                μ μ  μνμ€
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (playBaseInfo)
        //      WORK_BASE_HOLIDAY       κ³΅ν΄μΌ ν΄λ¬΄ μ¬λΆ (Y/N)
        //      WORK_STA_TIME           μμ μμ μκ°
        //      WORK_OUT_TIME           μμ μ’λ£ μκ°
        //      redCd                   κ²°κ³Ό μ½λ
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/getPlayInfo.do")
        apiManager.request(api: .getWorktime, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - λ§€μ₯ μ¬μ§ λ±λ‘
    /// λ§€μ₯ μ¬μ§ λ±λ‘
    func registerStorePicture(attachGrpSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                μ μ  μνμ€
        //      MASTER_SEQ              λ§μ€ν° μνμ€
        //      VECHILE_TYPE            004
        //      ATTACH_TYPE             μ΄λ―Έμ§μ μ²«μ₯μ 014λ‘ μ λ¬, λλ²μ§Έ μ₯λΆν° 013μΌλ‘ μ λ¬
        //      module                  3
        //      ATTACH_GRP_SEQ          μ²μ λ±λ‘μ κ°μ΄ μμ κ²½μ° μ λ¬ νμ§ μλλ€ (κ°μ΄ μμ κ²½μ°μλ§ μ λ¬)
        //      DEL_SEQ                 μ­μ ν  νμΌμ μνμ€
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq,
            "MASTER_SEQ": _user.masterSeq,
            "module": "3",
            "ATTACH_GRP_SEQ": attachGrpSeq,
            "ATTACH_TYPE": AttachType.storageMain.rawValue
//            "VECHILE_TYPE": "004",
//            "DEL_SEQ": delSeq
        ]
        
        let url = getRequestUrl(body: "/sys/saverV3/app/setPictureManage.do")
//        let attach: AttachForm = [("014", [main]), ("013", normal)]
//        apiManager.requestAttach(api: .registerStorePicture, url: url, headers: headers, parameters: param, attaches: attach, completion: completion)
        
        apiManager.request(api: .registerStorePicture, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - λ§€μ₯ μ¬μ§ μ‘°ν
    /// λ§€μ₯ μ¬μ§ μ‘°ν
    func getStorePictures(attachGrpSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                μ μ  μνμ€
        //      ATTACH_GRP_SEQ          μ¬μ§ κ·Έλ£Ή μνμ€ (κ°μ΄ μμ κ²½μ°μλ§ μ λ¬)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: [String: String] = [
            "USER_SEQ": _user.seq,
            "ATTACH_GRP_SEQ": attachGrpSeq,
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/getPictureList.do")
        apiManager.request(api: .getStorePicture, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - λ§€μ₯ μ¬μ§ μ­μ 
    /// λ§€μ₯ μ¬μ§ μ­μ 
    func deleteStorePicture(attachGrpSeq: String, attachSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      ATTACH_SEQ              μ¬μ§ μνμ€
        //      ATTACH_GRP_SEQ          μ¬μ§ κ·Έλ£Ή μνμ€ (κ°μ΄ μμ κ²½μ°μλ§ μ λ¬)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: [String: String] = [
            "ATTACH_SEQ": attachSeq,
            "ATTACH_GRP_SEQ": attachGrpSeq,
        ]
        
        let url = getRequestUrl(body: "/sys/attach/image/deleteFile.do")
        apiManager.request(api: .getStorePicture, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - λ§€μ₯μ λ³΄ λ±λ‘
    /// λ§€μ₯μ λ³΄ λ±λ‘
    func registerStoreInfo(pr: String, capacity: Int, attachGrpSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            μ¬μ©μ μνμ€
        //      MASTER_SEQ          λ§μ€ν° μνμ€
        //      MAX_BOX_CNT         λ³΄κ΄ κ°λ₯ μλ
        //      WAREHOUSE_ISSUE     μκ°κΈ
        //      ATTACH_GRP_SEQ      νμΌ κ·Έλ£Ή μνμ€
        //      module              μ²¨λΆνμΌ μ μ₯ κ³΅κ° μ½λ
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "MASTER_SEQ": _user.masterSeq,
            "MAX_BOX_CNT": capacity,
            "WAREHOUSE_ISSUE": pr,
            "ATTACH_GRP_SEQ": _user.attachGrpSeq,
            "module": "3"
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/setWayInsert.do")
        apiManager.request(api: .registerDayoff, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - μμμκ° λ±λ‘
    /// μμμκ° λ±λ‘
    func setWorktime(open: String, close: String, holiday: Bool = false, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            μ¬μ©μ μνμ€
        //      WORK_STA_TIME       μμ μμ μκ°
        //      WORK_OUT_TIME       μμ μ’λ£ μκ°
        //      WORK_BASE_HOLIDAY   κ³΅ν΄μΌ ν΄λ¬΄ μ¬λΆ (Y/N)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { completion?(false, nil); return }
        
        let holidayStr = holiday ? "Y" : "N"
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "WORK_STA_TIME": open,
            "WORK_OUT_TIME": close,
            "WORK_BASE_HOLIDAY": holidayStr,
        ]
        
        let url = getRequestUrl(body: "/sys/saver/app/setPlayInsert.do")
        apiManager.request(api: .registerWorktime, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - μκ°κΈ λ±λ‘
    /// μκ°κΈ λ±λ‘
    func registerPr(pr: String, vehicleSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ            μ μ  seq
        //      USER_VECHILE_SEQ    μ΄μ‘μλ¨ seq (getWayInfo.do μμ λ°μ)
        //      CARRYING_ISSUE      μκ°κΈ
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq,
            "USER_VECHILE_SEQ": vehicleSeq,
            "CARRYING_ISSUE": pr
        ]
        
        let urlString = "/sys/saverV2/app/setIusseUpdate.do"
        let url = getRequestUrl(body: urlString)
        apiManager.request(api: .registerPr, url: url, headers: headers, parameters: param, completion: completion)
    }
    

    // MARK: - μμ’ μ λ³΄
    /// μμ’ μ λ³΄
    func getCategories(completion: ResponseJson = nil) {
        guard let headers = getHeader() else { return }
        
        let urlString = "/sys/common/app/getCdBizTypeInfo.do"
        let url = getRequestUrl(body: urlString)
        apiManager.request(api: .getCategories, url: url, headers: headers, parameters: [:], completion: completion)
    }
    
    // MARK: - μμ’ λ±λ‘
    /// μμ’ λ±λ‘
    func registerCategory(category: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //      USER_SEQ            μ μ  seq
        //      MASTER_SEQ          λ§μ€ν° seq
        //      CD_BIZ_TYPE         μμ’ μ½λ
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: [String: String] = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq,
            "MASTER_SEQ": _user.masterSeq,
            "CD_BIZ_TYPE": category
        ]
        
        let urlString = "/sys/memberV2/app/setBizTypeUpdate.do"
        let url = getRequestUrl(body: urlString)
        apiManager.request(api: .registerCategories, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - μ§ λ³΄κ΄ κ°μ λ±λ‘
    /// μ§ λ³΄κ΄ κ°μ λ±λ‘
    func registerLuggages(luggageCount: Int, vehicleSeq: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //      USER_SEQ                μ μ  seq
        //      USER_VECHILE_SEQ        μ°¨λ seq
        //      BOX_CNT                 μ§ λ³΄κ΄ κ°μ
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_SEQ": _user.seq,
            "USER_VECHILE_SEQ": vehicleSeq,
            "BOX_CNT": luggageCount
        ]
        
        let url = getRequestUrl(body: "/sys/saverV3/app/setBoxCnt.do")
        apiManager.request(api: .registerLuggages, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - λ§€μ₯μ λ³΄ κ΄λ ¨ μ½λ μ‘°ν
    /// λ§€μ₯μ λ³΄ κ΄λ ¨ μ½λ μ‘°ν
    func getStorageCodes(all: Bool, codeGroup: StorageCodeGroup, completion: (([StorageCode]) -> Void)? = nil) {
        guard let headers = getHeader() else { completion?([]); return }
        
        var api: ApiType = .getCategories
        if codeGroup == .bank       { api = .getBanks }
        else if codeGroup == .weeks { api = .getWeeks }
        else if codeGroup == .merit { api = .getMerits }
        
        var param: [String: String] = [
            "USER_SEQ": _user.seq
        ]
        
        var url = ""
        if all {
            url = getRequestUrl(body: "/sys/common/app/getComCdList.do")
            param["comGrpCd"] = codeGroup.rawValue
        } else {
            url = getRequestUrl(body: "/sys/common/app/getOptionList.do")
            param["ITEM_GRP_CD"] = codeGroup.rawValue
        }
        
        apiManager.request(api: api, url: url, headers: headers, parameters: param) { (success, json) in
            guard let json = json, true == success else { completion?([]); return }
            
            var codes: [StorageCode] = []
            
            if all {
                let arr = json["comCdList"].arrayValue
                for val in arr {
                    let grp = val["COM_GRP_CD"].stringValue
                    let code = val["COM_CD"].stringValue
                    let name = val["COM_NM"].stringValue
                    let storageCode = StorageCode(grp: grp, code: code, name: name)
                    codes.append(storageCode)
                }
            } else {
                let arr = json["optionList"].arrayValue
                for val in arr {
                    let grp = val["ITEM_GRP_CD"].stringValue
                    let code = val["ITEM_COM_CD"].stringValue
                    let storageCode = StorageCode(grp: grp, code: code, name: "")
                    codes.append(storageCode)
                }
            }
                
            completion?(codes)
        }
    }
    
    // MARK: - λ§€μ₯ κ΄λ ¨ μ½λ λ±λ‘
    func registerCodes(codes: String, grpCd: String, completion: ResponseJson = nil) {
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                μ μ  seq
        //      ITEM_CD_ARR             λΆκ°κΈ°λ₯ μ½λ (','λ‘ κ΅¬λΆ)
        //      ITEM_GRP_CD             λΆκ°κΈ°λ₯ κ·Έλ£Ή μ½λ (StorageCodeGroup)
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq,
            "ITEM_CD_ARR": codes,
            "ITEM_GRP_CD": grpCd
        ]
        
        let url = getRequestUrl(body: "/sys/common/app/setOptionInsert.do")
        apiManager.request(api: .registerMerits, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    
    
    // MARK: - μΊλ¦¬νλ¦¬ κΈ°λ³Έ μκΈ μ‘°ν
    func getDefaultCosts(completion: ResponseJson = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                μ¬μ©μ μνμ€
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (basicPriceList)
        //      RATE_SEQ                κΈ°λ³Έ κ°κ²© μνμ€
        //      RATE_KIND               κΈ°λ³Έ κ°κ²© μ’λ₯
        //      RATE_USER_SECTION       κΈ°λ³Έ μ μ©μκ°
        //      RATE_USER_PRICE         κΈ°λ³Έ κ°κ²©
        //
        //      (overPriceList)
        //      RATE_SEQ                ν μ¦ κ°κ²© μνμ€
        //      RATE_KIND               ν μ¦ κ°κ²© μ’λ₯
        //      RATE_USER_SECTION       ν μ¦ μ μ©μκ°
        //      RATE_USER_PRICE         ν μ¦ κ°κ²©
        //
        //      (oneDayPriceList)
        //      RATE_SEQ                ν μ¦ κ°κ²© μνμ€
        //      RATE_KIND               ν μ¦ κ°κ²© μ’λ₯
        //      RATE_SECTION            ν μ¦ μ μ©μκ°
        //      RATE_PRICE              ν μ¦ κ°κ²©
        //
        //------------------------------------------------------------- //
                
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/price/app/getSaverBasicPriceRate.do")
        apiManager.request(api: .getDefaultCosts, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - λ΄κ° μ€μ ν μκΈ μ‘°ν
    func getMyCosts(completion: ResponseJson = nil) {
        
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                μ¬μ©μ μνμ€
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //      (basicPriceList)
        //      RATE_SEQ                κΈ°λ³Έ κ°κ²© μνμ€
        //      RATE_KIND               κΈ°λ³Έ κ°κ²© μ’λ₯
        //      RATE_USER_SECTION       κΈ°λ³Έ μ μ©μκ°
        //      RATE_USER_PRICE         κΈ°λ³Έ κ°κ²©
        //
        //      (overPriceList)
        //      RATE_SEQ                ν μ¦ κ°κ²© μνμ€
        //      RATE_KIND               ν μ¦ κ°κ²© μ’λ₯
        //      RATE_USER_SECTION       ν μ¦ μ μ©μκ°
        //      RATE_USER_PRICE         ν μ¦ κ°κ²©
        //
        //      (oneDayPriceList)
        //      RATE_SEQ                ν μ¦ κ°κ²© μνμ€
        //      RATE_KIND               ν μ¦ κ°κ²© μ’λ₯
        //      RATE_SECTION            ν μ¦ μ μ©μκ°
        //      RATE_PRICE              ν μ¦ κ°κ²©
        //
        //------------------------------------------------------------- //
                
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq
        ]
        
        let url = getRequestUrl(body: "/sys/price/app/getSaveUserPriceRate.do")
        apiManager.request(api: .getMyCosts, url: url, headers: headers, parameters: param, completion: completion)
    }
    
    // MARK: - λ³΄κ΄ κ°κ²© λ±λ‘
    func registerCosts(sequences: String, sections: String, costs: String, completion: ResponseJson = nil) {
        
        //-------------------------- Example -------------------------- //
        //
        //      /sys/price/app/setSaveUserPriceRate
        //      .do?USER_SEQ=1&CARRYING_PRICE_TYPE=002&CARRYING_SUP_PRICE=0&rate_seq=1,2,3&rate_user_section=4,4,4&rate_user_price=2000,3000,7000
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Request -------------------------- //
        //
        //      USER_SEQ                μ¬μ©μ μνμ€
        //      CARRYING_PRICE_TYPE     κ°κ²©μ μ± κ΅¬λΆ - 001 : μΊλ¦¬νλ¦¬κ°μΌλ‘ μ¬μ©, 002 : μ§μ  κ°κ²© μ±μ 
        //      CARRYING_SUP_PRICE      μΆκ°μκΈ
        //      rate_seq                κ°κ²© μνμ€ - μΊλ¦¬νλ¦¬ κΈ°λ³Έ κ°κ²©μ μνμ€λ₯Ό λ°μμ , λ‘ κ΅¬λΆνμ¬ μ λ¬νλ€. μ)1,2,3
        //
        //      rate_user_section       003 : μκ°λ¨μλ‘ νμκ°μ 1, λμκ°μ΄λ©΄ 2,2,2,2
        //                              004 : λΆλ¨μλ‘ 30λΆμΌ κ²½μ° 30, 1μκ°μΌ κ²½μ° 60
        //                              005 : μΌ λ¨μλ‘ 1μΌ μΌ κ²½μ° 1, 2μΌ μΌ κ²½μ° 2
        //
        //      rate_user_price         μ§ ν¬κΈ°λ³ κ°κ²© - κ΅¬κ° κ°κ²©μ μμ μ λ¬λ μνμ€ ν¬κΈ°λ§νΌ , λ‘ κ΅¬λΆνμ¬ μ λ¬νλ€. μ)2000,3000,7000
        //
        //
        //------------------------------------------------------------- //
        //
        //
        //
        //-------------------------- Response ------------------------- //
        //
        //
        //------------------------------------------------------------- //
        
        guard let headers = getHeader() else { return }
        
        let param: Parameters = [
            "USER_TYPE": CarrifreeAppType.appStorage.user,
            "USER_SEQ": _user.seq,
            "CARRYING_PRICE_TYPE": "N",
            "CARRYING_SUP_PRICE": "0",
            "rate_seq": sequences,
            "rate_user_section": sections,
            "rate_user_price": costs
        ]
        
        let url = getRequestUrl(body: "/sys/price/app/setSaveUserPriceRate.do")
        apiManager.request(api: .registerCosts, url: url, headers: headers, parameters: param, completion: completion)
    }
    
}


