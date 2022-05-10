//
//  StoreVm.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/10/26.
//

import Foundation
import SwiftyJSON

@objc protocol StoreVmDelegate {
    @objc optional func ready(msg: String)
}

class StoreVm: UploadVm {
    
    let maxPictureCount: Int = 10
    
    var delegate: StoreVmDelegate?
    var hidden: Bool = true
    var pictures: [PictureData] = []
    var open: String = ""
    var close: String = ""
    var dayoffs: [Weekday] = []
    var dayoffRegistered: Bool = false
    var dayoffInHoliday: Bool = false
    var pr: String = ""
    var prPlaceHolder = _strings[.meritsPlaceholder]
    var prMaxLength: Int = 500
    var luggages: Int = 0
    var vehicleSeq: String = ""
    var masterSeq: String = ""
    var category: StoreCategoryData!             // 현재 선택된 업종
    var categories: [StoreCategoryData] = []     // 모든 업종 종류
    
    var myMerits: [MeritData] = []               // 내 매장의 보관 장점
    var merits: [MeritData] = []                 // 모든 보관 장점
    var meritsGrpSeq: String = ""                // 보관 장점 그룹 시퀀스
    var meritsRegistered: Bool = false
    
    // 캐리프리 기본 가격
    var defaultCosts: [CostData] = []            // 1일 이내의 기본 가격
    var extraCosts: [CostData] = []              // 1일 이내의 추가 가격
    var dayCosts: [CostData] = []                // 1일 이후의 가격
    
    // 내가 설정한 가격
    var myDefaultCosts: [CostData] = []          // 1일 이내의 기본 가격
    var myExtraCosts: [CostData] = []            // 1일 이내의 추가 가격
    var myDayCosts: [CostData] = []              // 1일 이후의 가격
    
    var presignedUrl: String = ""
    var attachGrpSeq: String = _user.attachGrpSeq
    var attachSeq: String = ""
    var uploadedCount: Int = 0
    
    init(delegate: StoreVmDelegate) {
        self.delegate = delegate
        category = StoreCategoryData()
        getAllInfos()
    }
    
    // 매장의 모든 정보 조회
    func getAllInfos() {
        // 비동기 코드임! (헷갈리지 말것)
        var message: String = ""
        getCategories() { (success) in
        
        self.getStoreInfo() { (success, msg) in
            if false == msg.isEmpty { message = msg }
                
        self.getWorktime() { (success, msg) in
            if false == msg.isEmpty { message = msg }
                    
        self.getStorePicture(attachGrpSeq: self.attachGrpSeq) { (success, msg) in
            if false == msg.isEmpty { message = msg }
                        
        self.getDayoff(all: false, codeGroup: .weeks) { (success, msg) in
            if false == msg.isEmpty { message = msg }
                            
        self.getMerits(all: true, codeGroup: .merit) { (success) in
            if false == msg.isEmpty { message = msg }
                                
        self.getMerits(all: false, codeGroup: .merit) { (success) in
            if false == msg.isEmpty { message = msg }
                                    
        self.getDefaultCosts { (success, msg) in
            if false == msg.isEmpty { message = msg }
                                        
        self.getMyCosts() { (success, msg) in
            if false == msg.isEmpty { message = msg }
            self.delegate?.ready?(msg: message)
        }}}}}}}}}
    }
    
    // MARK: 매장 정보 조회
    /// 매장 정보 조회
    func getStoreInfo(completion: ResponseString = nil) {
        _cas.storeinfo.getStoreInfo() { (success, json) in
            guard let json = json else { return }
            
            guard success else {
                completion?(false, self.getFailedMsg(json: json))
                return
            }
            
            _cas.registration.getUserInfo() { (success, json) in
                if let json = json {
                    let user = BizData(json: json)
                    self.hidden = user.hidden
                    for category in self.categories {
                        if user.bizType == category.code { self.category = category; break }
                    }
                    
                    _user.masterSeq = json["MASTER_SEQ"].stringValue
                }
                completion?(true, "")
            }
            
            self.vehicleSeq = json["wayInfo"]["USER_VECHILE_SEQ"].stringValue
//            self.attachGrpSeq = json["wayInfo"]["ATTACH_GRP_SEQ"].stringValue
            self.pr = json["wayInfo"]["WAREHOUSE_ISSUE"].stringValue
            self.luggages = json["wayInfo"]["MAX_BOX_CNT"].intValue
            self.masterSeq = json["wayInfo"]["MASTER_SEQ"].stringValue
        }
    }
    
    // MARK: 영업시간 조회
    /// 영업시간 조회
    func getWorktime(completion: ResponseString = nil) {
        _cas.storeinfo.getWorkTime() { (success, json) in
            guard let json = json, true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "영업시간을 불러오지 못했습니다.", json: json))
                return
            }
            
            let val = json["playBaseInfo"]
            var open = val["WORK_STA_TIME"].stringValue
            var close = val["WORK_OUT_TIME"].stringValue
            for _ in 0 ... 2 { _ = open.popLast(); _ = close.popLast() }
            
            self.open = open
            self.close = close
            completion?(true, "")
        }
    }
    
    // MARK: 영업시간 등록
    /// 영업시간 등록
    func setWorktime(open: String, close: String, completion: ResponseString = nil) {
        _cas.storeinfo.setWorktime(open: open, close: close) { (success, json) in
            guard true == success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "영업시간을 불러오지 못했습니다.", json: json))
                return
            }
            
            completion?(true, "")
        }
    }
    
    // MARK: 노출/비노출 설정
    /// 노출/비노출 설정
    func setAppearance(appear: Bool, completion: ResponseString = nil) {
        _cas.general.setAppearance(appear: appear) { (success, json) in
            
            // 설정 요청이 실패했을 경우에만 핸들러 호출
            guard success else {
                if let json = json {
                    var message = json["resMsg"].stringValue
                    if message.isEmpty { message = _strings[.requestFailed] }
                    completion?(success, message)
                }
                
                return
            }
            
        }
    }
    
    // MARK: 매장 사진 조회
    /// 매장 사진 조회
    func getStorePicture(attachGrpSeq: String, completion: ResponseString = nil) {
        // attachGrpSeq가 빈값이면 사진이 등록되지않은 상태라서 return
        if attachGrpSeq.isEmpty {
            completion?(false, "")
            return
        }
        
        // 사진 조회
        _cas.storeinfo.getStorePictures(attachGrpSeq: attachGrpSeq) { (success, json) in
            guard let jsonValue = json else { return }
            
            if success {
                self.pictures.removeAll()
                
                // 보관 장소 메인 사진
                let picturesArr104 = jsonValue["majorPicList"].arrayValue
                for value in picturesArr104 {
                    let pictureSeq = value["ATTACH_SEQ"].stringValue
                    let pictureUrl = value["ATTACH_INFO"].stringValue
//                    self.attachGrpSeq = value["ATTACH_GRP_SEQ"].stringValue
                    
                    let pictureData = PictureData(seq: pictureSeq, url: pictureUrl)
                    //                CarryUser.pictures.pictureStorage.append(pictureData)
                    self.pictures.append(pictureData)
                }
                
                // 보관 장소 전/후면 사진
                let picturesArr102 = jsonValue["beforeAfterPicList"].arrayValue
                for value in picturesArr102 {
                    // 보관장소 사진 그룹 시퀀스
                    let pictureSeq = value["ATTACH_SEQ"].stringValue
                    let pictureUrl = value["ATTACH_INFO"].stringValue
                    let pictureData = PictureData(seq: pictureSeq, url: pictureUrl)
                    //                CarryUser.pictures.pictureStorage.append(pictureData)
                    self.pictures.append(pictureData)
                    
                }
                
                // 보관 장소 일반 사진
                let picturesArr103 = jsonValue["saverPicList"].arrayValue
                for value in picturesArr103 {
                    let pictureSeq = value["ATTACH_SEQ"].stringValue
                    let pictureUrl = value["ATTACH_INFO"].stringValue
                    let pictureData = PictureData(seq: pictureSeq, url: pictureUrl)
                    //                CarryUser.pictures.pictureStorage.append(pictureData)
                    self.pictures.append(pictureData)
                }
                
                completion?(true, "")
            } else {
                completion?(false, self.getFailedMsg(json: jsonValue))
            }

        }
    }
    
    // MARK: 매장 사진 등록
    /// 매장 사진 등록
    func registerStorePicture(main: Data?, normal: [Data?], completion: ResponseString = nil) {
        var imgs: [Data?] = [main]
        imgs.append(contentsOf: normal)
        self.uploadStoragePictures(imgDatas: imgs) { (success, msg) in
//            guard success else {
//                completion?(false, msg)
//                return
//            }
            
            _cas.storeinfo.registerStorePicture(attachGrpSeq: self.attachGrpSeq) { (success, json) in
                guard success else {
                    completion?(false, ApiManager.getFailedMsg(defaultMsg: "사진을 등록하지 못했습니다.", json: json))
                    return
                }
                
                completion?(true, "")
            }
            
        }
        
        
        /*
        _cas.storeinfo.registerStorePicture(main: main, normal: normal, delSeq: delSeq, attachGrpSeq: attachGrpSeq) { (success, json) in
            guard let json = json else { return }
            
            if success {
                self.initDelSeq()
                if self.vehicleSeq.isEmpty { self.vehicleSeq = json["resMsg"].stringValue }
                self.attachGrpSeq = json["attachGrpSeq"].stringValue
                completion?(success, "")
            } else {
                var message = json["resMsg"].stringValue
                if message.isEmpty { message = json.error.debugDescription }
                if message.isEmpty { message = _strings[.requestFailed] }
                completion?(success, message)
            }
        }
        */
        
    }
    
    // MARK: 매장 사진 삭제
    /// 매장 사진 삭제
    func deleteStorePicture(attachSeq: String, completion: ResponseString = nil) {
        _cas.storeinfo.deleteStorePicture(attachGrpSeq: self.attachGrpSeq, attachSeq: attachSeq) { (success, json) in
            guard success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "사진을 삭제하지 못했습니다.", json: json))
                return
            }
            
            completion?(true, "")
        }
    }
    
    /// 여러개의 이미지를 순서대로 업로드함
    func uploadStoragePictures(imgDatas: [Data?], completion: ResponseString = nil) {
        let maxUploadCount: Int = imgDatas.count
        guard maxUploadCount > 0 else { completion?(true, ""); return }
        uploadedCount = 0
        
        func upload(imgData: Data?, attachType: AttachType, completion: ResponseString = nil) {
            guard let imgData = imgData else {
                reUpload()
                return
            }
            
            uploadImage(imgData: imgData, attachType: attachType) { (success, msg) in
                reUpload()
            }
        }
        
        func reUpload() {
            if self.uploadedCount >= maxUploadCount - 1 {
                completion?(true, "")
                return
            }
            
            self.uploadedCount += 1
            upload(imgData: imgDatas[self.uploadedCount], attachType: .storageInside)
        }
        
        upload(imgData: imgDatas[uploadedCount], attachType: .storageInside)
    }
    
    // MARK: 쉬는날 조회
    /// 쉬는날 조회
    func getDayoff(all: Bool, codeGroup: StorageCodeGroup, completion: ResponseString = nil) {
        _cas.storeinfo.getStorageCodes(all: all, codeGroup: codeGroup) { (codes) in
            for code in codes {
                let dayoff = Weekday.getWeekday(type: code.code)
                self.dayoffs.append(dayoff)
            }
            
            completion?(true, "")
        }
    }
    
    // MARK: 쉬는날 등록/수정
    /// 쉬는날 등록/수정
    func registerDayoff(dayoffs: [Int], completion: ResponseString = nil) {
        var weekCodes: String = ""
        for dayoff in dayoffs {
            let weekType = (Weekday(rawValue: dayoff) ?? .none).type
            if weekType.isEmpty { continue }
            weekCodes += "\(weekType),"
        }
        
        // 휴무일은 지정하지않을 수 있기 때문에 값이 비어있으면 성공으로 처리함
        if weekCodes.isEmpty { completion?(true, "") }
        else { _ = weekCodes.popLast() }
        
        _cas.storeinfo.registerCodes(codes: weekCodes, grpCd: StorageCodeGroup.weeks.rawValue) { (success, json) in
            guard success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "쉬는날을 등록하지 못했습니다.", json: json))
                return
            }
            
            completion?(true, "")
        }
    }
    
    // MARK: 소개글 등록
    /// 소개글 등록
    func registerPr(pr: String, completion: ResponseString = nil) {
        _cas.storeinfo.registerPr(pr: pr, vehicleSeq: vehicleSeq) { (success, json) in
            if success {
                completion?(true, "")
                self.pr = pr
            } else {
                var msg = "\(_strings[.alertRegisterPrFailed]) \(_strings[.plzTryAgain])"
                if let json = json {
                    let failedMsg = json["resMsg"].stringValue
                    if false == failedMsg.isEmpty { msg = "\(msg)\n\(failedMsg)" }
                }
                
                completion?(false, msg)
            }
            
        }
    }
    
    // MARK: 업종 목록 조회
    /// 업종 목록 조회
    func getCategories(completion: requestCallback = nil) {
        _cas.storeinfo.getCategories() { (success, json) in
            guard let json = json else { completion?(false); return }
            
            self.categories.removeAll()
            let arr = json["bizTypeList"].arrayValue
            for value in arr {
                let code = value["COM_CD"].stringValue
                let name = value["COM_NM"].stringValue
                if code.isEmpty || name.isEmpty { continue }
                
                self.categories.append(StoreCategoryData(code: code, name: name))
            }
            
            if (success) {
                completion?(true)
            } else {
                let msg = "\(_strings[.alertLoadCategoryFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
                _log.log(msg)
                completion?(false)
            }
            
        }
    }
    
    // MARK: 업종 등록
    /// 업종 등록
    func registerCategory(selectedCategoryIndex: Int, completion: ResponseString = nil) {
        // 선택한 업종 코드
        let selectedCategoryCode = getCategoryCode(index: selectedCategoryIndex)
        
        // 동일한 업종 코드라면 API 요청하지않고 성공으로 처리함
        if selectedCategoryCode == category.code {
            _log.logWithArrow("업종 등록 성공", "동일한 업종을 선택했기때문에 성공으로 처리됨")
            completion?(true, "")
            return
        }
        
        // 등록 요청
        _cas.storeinfo.registerCategory(category: selectedCategoryCode) { (success, json) in
            var msg = ""
            if success {
                self.setCategoryCode(index: selectedCategoryIndex)
            } else {
                msg = "\(_strings[.alertRegisterCategoryFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
            }
            completion?(success, msg)
        }
    }
    
    func setCategoryCode(index: Int) {
        if index > categories.count - 1 { return }
        category = categories[index]
    }
    
    func getCategoryCode(index: Int) -> String {
        if index > categories.count - 1 { return "" }
        return categories[index].code
    }
    
    func getAllCategoryStrings() -> [String] {
        var selectedCetegories: [String] = []
        for c in categories {
            selectedCetegories.append(c.name)
        }
        
        return selectedCetegories
    }
    
    // MARK: 짐 보관 개수 등록
    /// 짐 보관 개수 등록
    func registerLuggages(luggageCount: Int, completion: ResponseString = nil) {
        // 기존과 동일한 개수를 입력했으면 API 요청하지않고 성공으로 처리함
        if luggages == luggageCount {
            let msg = _strings[.alertRegisterLuggageSuccess]
            _log.logWithArrow(msg, "동일한 개수를 입력했기때문에 성공으로 처리됨")
            completion?(true, msg)
            return
        }
        
        // 등록 요청
        _cas.storeinfo.registerLuggages(luggageCount: luggageCount, vehicleSeq: vehicleSeq) { (success, json) in
            var msg = ""
            if success {
                self.luggages = luggageCount
            } else {
                msg = "\(_strings[.alertRegisterLuggageFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
            }
            completion?(success, msg)
        }
    }
    
    // MARK: 보관 장점 조회
    /// 보관 장점 조회
    func getMerits(all: Bool, codeGroup: StorageCodeGroup, completion: requestCallback = nil) {
        _cas.storeinfo.getStorageCodes(all: all, codeGroup: codeGroup) { (codes) in
            for code in codes {
                let cd = code.code
                let name = StorageMerit(rawValue: cd)?.name ?? ""
                let merit = MeritData(code: cd, name: name, selected: false)
                
                if all { self.merits.append(merit) }
                else { self.myMerits.append(merit) }
            }
            
            completion?(true)
        }
    }
    
    func getMyMeritString(code: String) -> String {
        guard let merit = merits.filter({ $0.code == code }).first else { return "" }
        return merit.name
    }
    
    func getMyMeritsStrings() -> [String] {
        var selectedMerits: [String] = []
        for merit in myMerits {
            selectedMerits.append(merit.name)
        }
        
        return selectedMerits
    }
    
    func getAllMeritsStrings() -> [String] {
        var selectedMerits: [String] = []
        for merit in merits {
            selectedMerits.append(merit.name)
        }
        
        return selectedMerits
    }
    
    // MARK: 보관 장점 등록
    /// 보관 장점 등록
    func registerMerits(selectedMeritIndexes: [Int], completion: ResponseString = nil) {
        var selectedMeritsString: String = ""
        for index in selectedMeritIndexes {
            if index > merits.count - 1 { continue }
            let meritCode = merits[index].code
            selectedMeritsString += "\(meritCode),"
        }
        
        var myMeritsString: String = ""
        for merit in myMerits {
            myMeritsString += "\(merit.code),"
        }
        
        if myMeritsString == selectedMeritsString {
            let msg = _strings[.alertRegisterMeritsSuccess]
            _log.logWithArrow(msg, "동일한 보관 장점을 선택했기 때문에 성공으로 처리함")
            completion?(true, msg)
            return
        }
        
        _ = selectedMeritsString.popLast()
        _cas.storeinfo.registerCodes(codes: selectedMeritsString, grpCd: StorageCodeGroup.merit.rawValue) { (success, json) in
            var msg = ""
            if success {
                self.setMerits(selectedMeritIndexes: selectedMeritIndexes)
            } else {
                msg = "\(_strings[.alertRegisterMeritsFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
            }
            completion?(success, msg)
        }
    }
    
    func setMerits(selectedMeritIndexes: [Int]) {
        myMerits.removeAll()
        for (i, merit) in merits.enumerated() {
            for index in selectedMeritIndexes {
                if i == index { myMerits.append(merit); break }
            }
        }
    }
    
    // MARK: 기본 가격 조회
    func getDefaultCosts(completion: ResponseString = nil) {
        _cas.storeinfo.getDefaultCosts() { (success, json) in
            var msg = ""
            
            if let json = json, true == success {
                self.defaultCosts.removeAll()
                let defaultCostArr = json["basicPriceList"].arrayValue
                for val in defaultCostArr {
                    let cost = self.parseDefaultCosts(json: val)
                    self.defaultCosts.append(cost)
                }
                
                self.extraCosts.removeAll()
                let extraCostArr = json["overPriceList"].arrayValue
                for val in extraCostArr {
                    let cost = self.parseDefaultCosts(json: val)
                    self.extraCosts.append(cost)
                }
                
                self.dayCosts.removeAll()
                let dayCostArr = json["oneDayPriceList"].arrayValue
                for val in dayCostArr {
                    let cost = self.parseDefaultCosts(json: val)
                    self.dayCosts.append(cost)
                }
            } else {
                msg = "\(_strings[.alertLoadBasicCostFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
            }
                
            completion?(success, msg)
        }
    }
    
    // 기본 요금 parsing
    func parseDefaultCosts(json: JSON) -> CostData {
        let storageCost = CostData()
        storageCost.seq = json["RATE_SEQ"].stringValue
        storageCost.type = json["RATE_KIND"].stringValue
        storageCost.section = json["RATE_SECTION"].stringValue
        storageCost.price = json["RATE_PRICE"].stringValue
        storageCost.defaultPrice = json["RATE_PRICE"].stringValue
        return storageCost
    }
    
    // MARK: 내가 설정한 가격 조회
    func getMyCosts(completion: ResponseString = nil) {
        _cas.storeinfo.getMyCosts() { (success, json) in
            var msg = ""
            
            if let json = json, true == success {
                self.myDefaultCosts.removeAll()
                let defaultCostArr = json["basicPriceList"].arrayValue
                for val in defaultCostArr {
                    let cost = self.parseMyCosts(json: val)
                    self.myDefaultCosts.append(cost)
                }
                
                self.myExtraCosts.removeAll()
                let extraCostArr = json["overPriceList"].arrayValue
                for val in extraCostArr {
                    let cost = self.parseMyCosts(json: val)
                    self.myExtraCosts.append(cost)
                }
                
                self.myDayCosts.removeAll()
                let dayCostArr = json["oneDayPriceList"].arrayValue
                for val in dayCostArr {
                    let cost = self.parseMyCosts(json: val)
                    self.myDayCosts.append(cost)
                }
            } else {
                msg = "\(_strings[.alertLoadCostFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
            }
                
            completion?(success, msg)
        }
    }
    
    // 내가 설정한 가격 parsing
    func parseMyCosts(json: JSON) -> CostData {
        let storageCost = CostData()
        storageCost.seq = json["RATE_SEQ"].stringValue
        storageCost.type = json["RATE_KIND"].stringValue
        
        var section = json["RATE_USER_SECTION"].stringValue
        if section.isEmpty { section = json["RATE_SECTION"].stringValue }
        storageCost.section = section
        
        var price = json["RATE_USER_PRICE"].stringValue
        if price.isEmpty { price = json["RATE_PRICE"].stringValue }
        storageCost.price = price
        
        return storageCost
    }
    
    
    // 가격 데이터에서 가격 string을 가져옴
    func getCostStrings(costs: [CostData]) -> [String] {
        var costString: [String] = []
        for cost in costs {
            costString.append(cost.price)
        }
        
        return costString
    }
    
    
    // MARK: 보관 가격 등록
    func registerCosts(defaultCosts: [String], extraCosts: [String], dayCosts: [String], completion: ResponseString = nil) {
        let sequences = getRequestSeq()
        let sections = getRequestSection()
        let mycosts = getRequestCost(defaultCosts: defaultCosts, extraCosts: extraCosts, dayCosts: dayCosts)
        _cas.storeinfo.registerCosts(sequences: sequences, sections: sections, costs: mycosts) { (success, json) in
            var msg = ""
            if success {
                self.writeCosts(defaultCosts: defaultCosts, extraCosts: extraCosts, dayCosts: dayCosts)
            } else {
                msg = "\(_strings[.alertRegisterCostFailed]) \(_strings[.plzTryAgain])\n\(self.getFailedMsg(json: json))"
            }
            completion?(success, msg)
        }
    }
    
    // 가격 등록시 보낼 시퀀스
    func getRequestSeq() -> String {
        var allSeq: [String] = []
        var allSeqStr = ""
        let separator = ","
        
        for cost in myDefaultCosts { allSeq.append(cost.seq) }
        for cost in myExtraCosts { allSeq.append(cost.seq) }
        for cost in myDayCosts { allSeq.append(cost.seq) }
        
        for seq in allSeq { allSeqStr = "\(allSeqStr)\(seq)\(separator)" }
//        if extras.count > 0 { allSeqStr.removeLast() }
        allSeqStr.removeLast()
        
        return allSeqStr
    }
    
    // 가격 등록시 보낼 섹션
    func getRequestSection() -> String {
        var allSeq: [String] = []
        var allSeqStr = ""
        let separator = ","
        
        for cost in myDefaultCosts { allSeq.append(cost.section) }
        for cost in myExtraCosts { allSeq.append(cost.section) }
        for cost in myDayCosts { allSeq.append(cost.section) }
        
        for seq in allSeq { allSeqStr = "\(allSeqStr)\(seq)\(separator)" }
//        if extras.count > 0 { allSeqStr.removeLast() }
        allSeqStr.removeLast()
        
        return allSeqStr
    }
    
    // 가격 등록시 보낼 가격
    func getRequestCost(defaultCosts: [String], extraCosts: [String], dayCosts: [String]) -> String {
        var allSeq: [String] = []
        var allSeqStr = ""
        let separator = ","
        
        for cost in defaultCosts { allSeq.append(_utils.getStringFromDelemiter(str: cost)) }
        for cost in extraCosts { allSeq.append(_utils.getStringFromDelemiter(str: cost)) }
        for cost in dayCosts { allSeq.append(_utils.getStringFromDelemiter(str: cost)) }
        
        for seq in allSeq { allSeqStr = "\(allSeqStr)\(seq)\(separator)" }
//        if extras.count > 0 { allSeqStr.removeLast() }
        allSeqStr.removeLast()
        
        return allSeqStr
    }
    
    // MARK: 매장 정보(소개글, 보관 개수) 등록
    /// 매장 정보 등록(소개글, 보관 개수)
    func registerStoreInfo(pr: String, capacity: Int, completion: ResponseString = nil) {
        _cas.storeinfo.registerStoreInfo(pr: pr, capacity: capacity, attachGrpSeq: attachGrpSeq) { (success, json) in
            guard success else {
                completion?(false, ApiManager.getFailedMsg(defaultMsg: "매장정보를 등록하지 못했습니다.", json: json))
                return
            }
            
            completion?(true, "")
        }
    }
    
    // MARK: - 매장정보 등록 완료
    /// 매장정보 등록 완료
    func requestApprove(completion: ResponseString = nil) {
        _cas.registration.requestApprove(isStoreInfo: true) { (success, json) in
            if success {
                _user.stored = true
                completion?(true, _strings[.alertRequestWriteStoreSuccess])
            } else {
                var msg = "\(_strings[.alertRequestApproveFailed]) \(_strings[.plzTryAgain])"
                if let json = json {
                    let failedMsg = json["resMsg"].stringValue
                    if false == failedMsg.isEmpty { msg = "\(msg)\n(\(failedMsg))" }
                }
                completion?(false, msg)
            }
        }
    }
    
    func removeDelimiter(costStrings: inout [String]) {
        for i in 0 ..< costStrings.count {
            let str = _utils.removeDelimiter(str: costStrings[i])
            costStrings[i] = str
        }
    }
    
    func writeCosts(defaultCosts: [String], extraCosts: [String], dayCosts: [String]) {
        for (i, cost) in myDefaultCosts.enumerated() {
            if i > defaultCosts.count - 1 { break }
            cost.price = defaultCosts[i]
        }
        
        for (i, cost) in myExtraCosts.enumerated() {
            if i > extraCosts.count - 1 { break }
            cost.price = extraCosts[i]
        }
        
        for (i, cost) in myDayCosts.enumerated() {
            if i > dayCosts.count - 1 { break }
            cost.price = dayCosts[i]
        }
    }
    
    func getFailedMsg(json: JSON?) -> String {
        guard let json = json else { return "" }
        var message = json["resMsg"].stringValue
        if message.isEmpty { message = _strings[.requestFailed] }
        return message
    }
}

