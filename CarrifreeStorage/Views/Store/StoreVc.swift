//
//  StoreVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/26.
//

import UIKit
import Mantis
import PhotosUI

protocol StoreVcDelegate {
    func storeVcDeleted()
    func registeredStore()
}

class StoreVc: UIViewController {
    
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleViewHeightConstraint: NSLayoutConstraint!
    
    // hidden (store info)
    @IBOutlet weak var hiddenTitle: UILabel!
    @IBOutlet weak var storeInfo: UILabel!
    @IBOutlet weak var hidden: UISegmentedControl!
    @IBOutlet weak var hiddenDesc: UILabel!
    
    // photos
    @IBOutlet weak var pictureTitle: UILabel!
    @IBOutlet weak var pictureStack: UIStackView!
    @IBOutlet weak var pictureDesc: UILabel!
    @IBOutlet weak var pictureReg: UIImageView!
    @IBOutlet weak var pictureCount: UILabel!
    
    // time, date
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var open: RegTime!
    @IBOutlet weak var close: RegTime!
    @IBOutlet weak var dayoff: RegDate!
    
    // pr
    @IBOutlet weak var prTitle: UILabel!
    @IBOutlet weak var pr: UITextView!
    @IBOutlet weak var prLength: UILabel!
    
    // category
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var category: ToggleCollection!
//    @IBOutlet weak var categoryStatus: UILabel!
    
    // luggage
    @IBOutlet weak var luggageTitle: UILabel!
    @IBOutlet weak var luggage: UITextField!
    @IBOutlet weak var luggageEa: UILabel!
    @IBOutlet weak var luggageStatus: UILabel!
    
    // feature
    @IBOutlet weak var meritsTitle: UILabel!
    @IBOutlet weak var merits: ToggleCollection!
//    @IBOutlet weak var meritsStatus: UILabel!
    
    // cost
    @IBOutlet weak var costTitle: UILabel!
    @IBOutlet weak var cost: CostBoard!
    @IBOutlet weak var costStatus: UILabel!
    @IBOutlet weak var defaultCost: UIButton!
    
    
    // request
    @IBOutlet weak var request: UIButton!
    
    let cropRectRatio: Double = 16.0 / 10.0
    let pictureCellWidth: CGFloat = 97
    
    var vm: StoreVm!
    var phConfiguration: PHPickerConfiguration!
    var pictureCells: [RegStoragePictureCell] = []
    
    var delegate: StoreVcDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        update()
    }
    
    func configure() {
        if let _ =  self.navigationController {
            titleView.isHidden = true
            titleViewHeightConstraint.constant = 10
            self.navigationItem.title = _strings[.enterStoreInfo]
            self.navigationController?.navigationBar.tintColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        } else {
            vcTitle.text = _strings[.enterStoreInfo]
            vcTitle.font = UIFont(name: "NanumSquareB", size: 17)
        }
        
        phConfiguration = PHPickerConfiguration()
        phConfiguration.filter = .images
        phConfiguration.selectionLimit = 10
        
        initHidden()
        initPhotos()
        initWorkTime()
        initPr()
        initCatetory()
        initLuggage()
        initFeatures()
        initCost()
        initRequest()
    }
    
    func initHidden() {
        hiddenTitle.text = _strings[.setVisible]
        hiddenTitle.font = titleFont
        
        storeInfo.text = _strings[.storageInfo]
        storeInfo.font = UIFont(name: "NanumSquareB", size: 17)
        
        let segTitles = [_strings[.invisible], _strings[.visible]]
        for (i, title) in segTitles.enumerated() {
            hidden.setTitle(title, forSegmentAt: i)
        }
        
        let selectedColor = UIColor(red: 152/255, green: 196/255, blue: 85/255, alpha: 1)
        let normalFont = UIFont(name: "NanumSquareR", size: 15) ?? UIFont.systemFont(ofSize: 15)
        let selectedFont = UIFont(name: "NanumSquareB", size: 15) ?? UIFont.systemFont(ofSize: 15)
        hidden.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: normalFont], for: .normal)
        hidden.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor, NSAttributedString.Key.font: selectedFont], for: .selected)
        hidden.addTarget(self, action: #selector(self.onSegmentValueChanged(_:)), for: .valueChanged)
        
        // 세그먼트에서 선택된(움직이는) 뷰의 borderWidth와 border 컬러를 직접 바꿀수 없기때문에 그것을 표현할 view를 새로 생성함
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)) {
            if self.hidden.numberOfSegments >= segTitles.count {
                
                // 선택된 view 추출 (세그먼트의 개수와 일치하는 인덱스에 있음)
                let selectedSegIndex = segTitles.count
                let selectedSeg = self.hidden.subviews[selectedSegIndex]
                
                // border를 표시할 view 생성
                let borderView = UIView(frame: CGRect(x: 4, y: 5, width: selectedSeg.frame.width - 8, height: selectedSeg.frame.height - 10))
                borderView.backgroundColor = .clear
                borderView.layer.cornerRadius = 6
                borderView.layer.borderWidth = 1
                borderView.layer.borderColor = selectedColor.cgColor
                self.hidden.subviews[selectedSegIndex].addSubview(borderView)
            }
        }
        
        hiddenDesc.numberOfLines = 0
        _utils.setText(bold: .regular, size: 12, text: _strings[.visibleDesc], color: .systemGray, label: hiddenDesc)
    }
    
    func initPhotos() {
        pictureTitle.text = _strings[.registerStorePic]
        pictureTitle.font = titleFont
        
        _utils.setText(bold: .regular, size: 12, text: _strings[.registerStorePicDesc], color: .systemGray, label: pictureDesc)
        
        pictureReg.isUserInteractionEnabled = true
        pictureReg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onRegPicture(_:))))
    }
    
    func initRequest() {
        request.setTitle(_strings[.registerStoreInfo], for: .normal)
        request.titleLabel?.font = UIFont(name: "NanumSquareB", size: 18)
        request.addTarget(self, action: #selector(self.onRequest(_:)), for: .touchUpInside)
    }
    
    func initWorkTime() {
        timeTitle.text = _strings[.registerWorkTime]
        open.configure(title: "\(_strings[.opentime]):", time: "10:00")
        open.delegate = self
        close.configure(title: "\(_strings[.closetime]):", time: "20:00")
        close.delegate = self
        dayoff.configure(selectedDays: [], selectedHoliday: false)
    }
    
    func initPr() {
        prTitle.text = _strings[.enterPr]
        
        pr.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        pr.backgroundColor = .systemGray6
        pr.delegate = self
    }
    
    func initCatetory() {
        categoryTitle.text = _strings[.alertSelectStoreCategory]
        categoryTitle.font = titleFont
        
        category.configure(multiSelectable: false, toggleTitles: [])
        category.invalidStatusString = _strings[.alertSelectStoreCategory]
//        categoryStatus.text = "최소 1개 이상 선택하셔야 합니다."
//        categoryStatus.font = descFont02
    }
    
    /*
     case enterStoreInfo = "매장정보 입력"
     case setVesible = "보관사업자 게시 상태 설정"
     case visible = "노출"
     case invisible = "비노출"
     case visibleDesc = "영업이 바쁘거나 갑작스럽게 영업이 어려운 경우 ‘비노출’로 설정하시면 사용자앱에서 검색시 노출되지 않습니다."
     case registerStorePic = "매장사진을 등록해주세요.(최대 10개)"
     case registerStorePicDesc = "버튼을 눌러 매장사진을 등록하세요. 대표사진 1개는 등록되어야 매장 정보를 노출시킬 수 있습니다."
     case registerStoreInfo = "매장정보 등록/수정"
     case registerWorkTime = "매장 운영시간을 등록해주세요."
     case opentime = "시작시간"
     case closetime = "종료시간"
     case enterPr = "매장 소개글을 적어주세요."
     case enterLuggagesTitle = "짐 보관은 최대 몇개까지 가능하신가요?"
     case enterLuggages = "보관 가능한 짐 개수를 입력해주세요"
     case wrongLuggages = "짐 보관 수량을 올바르게 입력해주세요."
     case ea = "개"
     case enterMerits = "보관 장점을 선택하세요."
     case emptyMerits = "보관 장점을 1개 이상 선택해주세요"
     case enterCosts = "보관가격을 설정해주세요."
     case usingCarrifreeCosts = "캐리프리 시세 반영"
     case needDefaultSotrePic = "업체(매장) 사진을 1장 이상 등록해주세요"
     case wrongWorktime = "근무 시간을 올바르게 입력해주세요"
     case wrongCosts = "가격을 올바르게 설정해주세요."
     case registerStore = "매장정보 등록"
     case needPhotoAccessPermission = "사진 접근 권한이 필요합니다. '확인'을 선택하면 사진 접근 설정 화면으로 이동합니다."
     case alertPictureSelectionErr = "사진 선택 오류"
     
     */
    
    func initLuggage() {
        luggageTitle.text = _strings[.enterLuggagesTitle]
        luggageTitle.font = titleFont
        
        luggageStatus.text = _strings[.wrongLuggages]
        luggageStatus.font = descFont02
        
        let luggageFont = UIFont(name: "NanumSquareB", size: 26)
        luggage.font = luggageFont
        luggage.addTarget(self, action: #selector(self.onLuggageTextChanged(_:)), for: .editingChanged)
        
        luggageEa.text = _strings[.ea]
        luggageEa.font = luggageFont
    }
    
    func initFeatures() {
        meritsTitle.text = _strings[.enterMerits]
        meritsTitle.font = titleFont
        
        merits.configure(multiSelectable: true, toggleTitles: [])
        merits.invalidStatusString = _strings[.emptyMerits]
//        meritsStatus.text = "최소 1개 이상 선택하셔야 합니다."
//        meritsStatus.font = descFont02
    }
    
    func initCost() {
        costTitle.text = _strings[.enterCosts]
        costTitle.font = titleFont
        
        costStatus.font = descFont02
        costStatus.isHidden = true
        
        defaultCost.setTitle(_strings[.usingCarrifreeCosts], for: .normal)
        defaultCost.titleLabel?.font = fieldFont
        defaultCost.layer.borderWidth = 1
        defaultCost.layer.borderColor = defaultCost.titleColor(for: .normal)?.cgColor
        defaultCost.addTarget(self, action: #selector(self.onDefaultCost(_:)), for: .touchUpInside)
//        cost.configure(defaultCosts: ["1000", "1000", "1000", "1000"], extraCosts: ["2000", "2000", "2000", "2000"], dayCosts: ["3000", "3000", "3000", "3000"])
    }
    
    func update() {
        vm = nil
        vm = StoreVm(delegate: self)
    }
    
    func refresh() {
        // segment
        if vm.hidden {
            hidden.selectedSegmentIndex = 0
        } else {
            hidden.selectedSegmentIndex = 1
        }
        
        onSegmentValueChanged(hidden)
        
        // pictures
        for i in 0 ..< vm.maxPictureCount {
            let pictureCell = RegStoragePictureCell()
            let isMain = (i == 0)
            pictureCell.configure(isMain: isMain)
            pictureCell.updateMainStatus(isMain: false)
            pictureStack.addArrangedSubview(pictureCell)
            pictureCell.widthAnchor.constraint(equalToConstant: pictureCellWidth).isActive = true
            pictureCell.delegate = self
            pictureCell.mulitpleSelection = true
            pictureCells.append(pictureCell)
        }
        
        for (i, pictureData) in vm.pictures.enumerated() {
            if i >= pictureCells.count { continue }
            pictureCells[i].setImageWithUrl(url: pictureData.url, registered: false, seq: pictureData.seq)
        }
        
        pictureCount.text = "\(vm.pictures.count) / \(vm.maxPictureCount)"
        
        // dayoff
        dayoff.refresh(selectedDays: vm.dayoffs, selectedHoliday: vm.dayoffInHoliday)
        
        // time
        open.setTime(time: vm.open)
        close.setTime(time: vm.close)
        
        // pr
        if vm.pr.isEmpty {
            prLength.text = "0/\(vm.prMaxLength)"
            _utils.setText(bold: .regular, size: 14, text: vm.prPlaceHolder, color: .systemGray, textview: pr)
        } else {
            prLength.text = "\(pr.text.count)/\(vm.prMaxLength)"
            _utils.setText(bold: .regular, size: 14, text: vm.pr, textview: pr)
        }
        
        // luggage
        if vm.luggages > 0 { luggage.text = "\(vm.luggages)" }
        
        // category
        category.configure(multiSelectable: false, toggleTitles: vm.getAllCategoryStrings())
        category.select(title: vm.category.name)
        
        // merits
        merits.configure(multiSelectable: true, toggleTitles: vm.getAllMeritsStrings())
        merits.select(titles: vm.getMyMeritsStrings())
        
        // my costs
        var defaultCosts = vm.getCostStrings(costs: vm.myDefaultCosts)
        var extraCosts = vm.getCostStrings(costs: vm.myExtraCosts)
        var dayCosts = vm.getCostStrings(costs: vm.myDayCosts)
        cost.configure(defaultCosts: defaultCosts, extraCosts: extraCosts, dayCosts: dayCosts)
        
        // default cost
        defaultCosts.removeAll(); defaultCosts = vm.getCostStrings(costs: vm.defaultCosts)
        extraCosts.removeAll(); extraCosts = vm.getCostStrings(costs: vm.extraCosts)
        dayCosts.removeAll(); dayCosts = vm.getCostStrings(costs: vm.dayCosts)
        cost.setDefaultCosts(defaultCosts: defaultCosts, extraCosts: extraCosts, dayCosts: dayCosts)
    }
    
    // 사진 추가
    func insertPicture(img: UIImage) {
        // 비어있는 cell 중 첫번째에 사진을 추가함
        for cell in pictureCells {
            if cell.isEmpty {
                cell.setImageWithImage(image: img, registered: true, seq: cell.seq)
                break
            }
        }
        
        updatePictureCount()
        updatePictureDesc()
    }
    
    /// 사진 개수 text 갱신
    func updatePictureCount() {
        
        var currentPictureCount: Int = 0
        for cell in pictureCells {
            if false == cell.isEmpty { currentPictureCount += 1 }
        }
        
        pictureCount.text = "\(currentPictureCount) / \(vm.maxPictureCount)"
    }
    
    // MARK: 유효성 검사 후 매장정보 등록
    func validateAndRegister() {
        self.view.endEditing(true)
        
        var isValid = true
        
        let pictureIsEmpty = pictureIsEmpty()
        updatePictureDesc()
        if pictureIsEmpty {
            _log.log("사진 비어있음!")                        // 사진 비어있음
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.needDefaultSotrePic])
            isValid = false
        }
        
        let timeIsValid = validateTime()
        open.updateStatus(valid: timeIsValid)
        close.updateStatus(valid: timeIsValid)
        if false == timeIsValid {
            _log.log("잘못된 근무시간!")                       // 잘못된 근무 시간
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.wrongWorktime])
            isValid = false
        }
        
        category.updateStatus(valid: category.isSelected, invalidString: _strings[.alertSelectStoreCategory])
//        categoryStatus.isHidden = category.isSelected
        if false == category.isSelected {
            _log.log("업종 비어있음!")                        // 업종 비어있음
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.alertSelectStoreCategory])
            isValid = false
        }
        
        let luggageCount = Int(luggage.text ?? "") ?? 0
        luggageStatus.isHidden = (luggageCount > 0)
        if luggageCount <= 0 {
            _log.log("짐 개수 비어있음!")                      // 짐 개수 비어있음
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.enterLuggages])
            isValid = false
        }

        merits.updateStatus(valid: category.isSelected, invalidString: _strings[.emptyMerits])
//        meritsStatus.isHidden = merits.isSelected
        if false == merits.isSelected {
            _log.log("보관 장점 비어있음!")                     // 보관 장점 비어있음
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.emptyMerits])
            isValid = false
        }
        
        let isValidCost = cost.isValid
        costStatus.isHidden = isValidCost
        cost.validate()
        if false == isValidCost {
            costStatus.text = _strings[.wrongCosts]
            _log.log("가격 비어있음!")                         // 가격 비어있음
            isValid = false
        }
        
        guard isValid else { return }
        
        // 비동기 코드임! (헷갈리지 말것)
        var allSuccess: Bool = false
        if false == _utils.createIndicator() { return }
        
        self.registerWorkTime() { (success) in if success == false { allSuccess = success }
            
        self.registerDayoff() { (success) in if success == false { allSuccess = success }       // 휴뮤일 등록
        
        self.registerCategory() { (success) in if success == false { allSuccess = success }     // 업종 등록
        
        self.registerMerits() { (success) in if success == false { allSuccess = success }       // 보관 장점 등록
        
        self.registerCost() { (success) in if success == false { allSuccess = success }         // 가격 등록
        
        self.registerStoreInfo() { (success) in if success == false { allSuccess = success }    // 보관수량, 소개글 등록
        
        self.writeStore() { (success, _) in if success == false { allSuccess = success }
        
        self.registerPictures() { (success) in if success == false { allSuccess = success }
            
        allSuccess = success
        _utils.removeIndicator()
        self.delegate?.registeredStore()
        if allSuccess { self.createSimpleAlert(title: "완료", msg: "매장정보가 등록되었습니다") }
            
        }}}}}}}}
    }
    
    // 시간값 유효성 확인
    func validateTime() -> Bool {
        let startTime = open.getTime()
        let endTime = close.getTime()
        return startTime != endTime
    }
    
    // 사진의 개수에따라 text 갱신
    func updatePictureDesc() {
        let isEmpty = pictureIsEmpty()
        if isEmpty {
            pictureDesc.text = _strings[.needDefaultSotrePic]
            pictureDesc.textColor = .systemRed
        } else {
            pictureDesc.text = _strings[.registerStorePicDesc]
            pictureDesc.textColor = .systemGray
        }
    }
    
    // 사진이 모두 비어있는 상태인지 확인
    func pictureIsEmpty() -> Bool {
        var empty: Bool = true
        for cell in pictureCells {
            if cell.isEmpty == false { empty = false }
        }
        
        return empty
    }
    
    // MARK: 사진 등록 요청
    func registerPictures(completion: requestCallback = nil) {
        var isRegistered: Bool = false
        var mainPicture: Data? = nil
        var normalPictures: [Data?] = []
        for cell in pictureCells {
            guard cell.registered else { continue }     // 새로 등록된 것들 중
            isRegistered = true
            let imgData = cell.getImageData()
            if cell.isMain {                            // 메인 사진과
                mainPicture = imgData
            } else {                                    // 일반 사진을 구분함
                normalPictures.append(imgData)
            }
        }
        
        // 기존에 등록된 사진이 있는 상태에서 새로 추가한 사진이 없으면 성공으로 처리함
        if false == isRegistered { completion?(true); return }

        // 메인/일반 사진 등록 요청
        vm.registerStorePicture(main: mainPicture, normal: normalPictures) { (success, msg) in
            if success {
                // 사진 등록 상태 해제
                for cell in self.pictureCells { cell.registered = false }
            } else {
                self.createSimpleAlert(title: msg, msg: "")
            }
            
            completion?(success)
        }
    }
    
    // MARK: 휴무일 등록
    func registerDayoff(completion: requestCallback = nil) {
//        let startTime = open.getTime()
//        let endTime = close.getTime()
//        let selectedDays = dayoff.getSelectedDayString()
//        let dayoffInHoliday = dayoff.isDayoffInHoilday()
        
        let selectedDays = dayoff.getSelectedDays()
        vm.registerDayoff(dayoffs: selectedDays) { (success, msg) in
            if false == success { self.createSimpleAlert(title: msg, msg: "") }
            completion?(success)
        }
    }
    
    // MARK: 영업시간 등록
    func registerWorkTime(completion: requestCallback = nil) {
        let openStr = "\(open.getTime())"
        let closeStr = "\(close.getTime())"
        vm.setWorktime(open: openStr, close: closeStr) { (success, msg) in
            if false == success { self.createSimpleAlert(title: msg, msg: "") }
            completion?(success)
        }
    }
    
    // MARK: 소개글 등록
    func registerPr(completion: requestCallback = nil) {
        let prStr = self.pr.text ?? ""
        if prStr.isEmpty {
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.alertNeedEnterStorageIntroduction])
            completion?(false)
            return
        }
        
        self.vm.registerPr(pr: prStr) { (success, msg) in
            if false == success { self.createSimpleAlert(title: msg, msg: "") }
            completion?(success)
        }
    }
    
    // MARK: 업종 등록
    func registerCategory(completion: requestCallback = nil) {
        let selectedToggleIndexes = category.getSelectedIndexes()
        if selectedToggleIndexes.count == 0 {
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.alertSelectStoreCategory])
            completion?(false)
            return
        }
        vm.registerCategory(selectedCategoryIndex: selectedToggleIndexes[0]) { (success, msg) in
            if false == success { self.createSimpleAlert(title: msg, msg: "") }
            completion?(success)
        }
        
    }
    
    // MARK: 짐 보관 개수 등록
    func registerLuggages(completion: requestCallback = nil) {
        guard let luggageString = luggage.text else {
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.enterLuggages])
            completion?(false)
            return
        }
        guard let luggageCount = Int(luggageString) else {
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.enterLuggages])
            completion?(false)
            return
        }
        
        vm.registerLuggages(luggageCount: luggageCount) { (success, msg) in
            if false == success { self.createSimpleAlert(title: msg, msg: "") }
            completion?(success)
        }
    }
    
    // MARK: 보관 장점 등록
    func registerMerits(completion: requestCallback = nil) {
        let selectedMeritIndexes = merits.getSelectedIndexes()
        if selectedMeritIndexes.count == 0 {
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.emptyMerits])
            completion?(false)
            return
        }
        
        vm.registerMerits(selectedMeritIndexes: selectedMeritIndexes) { (success, msg) in
            if false == success { self.createSimpleAlert(title: msg, msg: "") }
            completion?(success)
        }
    }
    
    // MARK: 가격 등록
    func registerCost(completion: requestCallback = nil) {
        let defaultCostStrings = cost.getDefaultCostStrings()
        let extraCostStrings = cost.getExtraCostStrings()
        let dayCostStrings = cost.getDayCostStrings()
        vm.registerCosts(defaultCosts: defaultCostStrings, extraCosts: extraCostStrings, dayCosts: dayCostStrings) { (success, msg) in
            if false == success { self.createSimpleAlert(title: msg, msg: "") }
            completion?(success)
        }
    }
    
    // MARK: 매장 정보(소개글, 보관 개수) 등록
    /// 매장 정보 등록(소개글, 보관 개수)
    func registerStoreInfo(completion: requestCallback = nil) {
        let prStr = self.pr.text ?? ""
        if prStr.isEmpty {
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.alertNeedEnterStorageIntroduction])
            completion?(false)
            return
        }
        
        guard let luggageString = luggage.text else {
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.enterLuggages])
            completion?(false)
            return
        }
        guard let luggageCount = Int(luggageString) else {
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.enterLuggages])
            completion?(false)
            return
        }
        
        vm.registerStoreInfo(pr: prStr, capacity: luggageCount) { (success, msg) in
            if false == success { self.createSimpleAlert(title: msg, msg: "") }
            completion?(success)
        }
    }
    
    // MARK: 매장 정보 등록 완료
    func writeStore(completion: ResponseString) {
        self.vm.requestApprove() { (success, msg) in
//            _utils.removeIndicator()
            
            if success { }
            else { self.createSimpleAlert(title: msg, msg: "") }
            completion?(success, msg)
        }
    }
    
    func openGallery() {
        let phPickerVc = PHPickerViewController(configuration: phConfiguration)
        phPickerVc.delegate = self
        self.present(phPickerVc, animated: true)
    }
    
    func createSimpleAlert(title: String, msg: String) {
        let alert = _utils.createSimpleAlert(title: title, message: msg, buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
}

// MARK: - Actions
extension StoreVc {
    @IBAction func onExit(_ sender: UIButton) {
        self.view.removeFromSuperview()
        self.removeFromParent()
        delegate?.storeVcDeleted()
    }
    
    @objc func onSegmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {       // 비노출
            vm.setAppearance(appear: false)
        } else {                                    // 노출
            vm.setAppearance(appear: true)
        }
    }
    
    @objc func onRegPicture(_ sender: UIGestureRecognizer) {
        let accessLevel: PHAccessLevel = .readWrite
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        switch authorizationStatus {
        case.authorized, .limited: openGallery()
        default:
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { authorizationStatus in
                switch authorizationStatus {
                case .limited, .authorized: self.openGallery()
                default:
                    DispatchQueue.main.async {
                        let msg = _strings[.needPhotoAccessPermission]
                        let ok = _utils.createAlertAction(title: _strings[.ok]) { (_) in _utils.goToSettingsCarrifree() }
                        let alert2 = _utils.createAlert(title: _strings[.photo], message: msg, handlers: [ok], style: .alert, addCancel: true)
                        self.present(alert2, animated: true)
                    }
                }
            }
        }
    }
    
    @objc func onDefaultCost(_ sender: UIButton) {
        cost.setCostsForDefault()
    }
    
    @objc func onRequest(_ sender: UIButton) {
        validateAndRegister()
    }
    
    @objc func onLuggageTextChanged(_ sender: UITextField) {
        luggageStatus.isHidden = true
    }
}

// MARK: - StoreVmDelegate
extension StoreVc: StoreVmDelegate {
    func ready(msg: String) {
        if msg.isEmpty {
//            createSimpleAlert(title: _strings[.storeInfo], msg: "매장정보가 등록되었습니다")
        } else {
            createSimpleAlert(title: _strings[.storeInfo], msg: msg)
        }
        
        DispatchQueue.main.async {
            self.refresh()
        }
    }
}
    
// MARK: - CropViewControllerDelegate
/*
extension StoreVc: CropViewControllerDelegate {
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {}
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {}
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {}
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: true, completion: nil)
        insertPicture(img: cropped)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
*/


// MARK: - UITextViewDelegate
extension StoreVc: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView == pr) && (textView.text == vm.prPlaceHolder) {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let textLength = textView.text.count
        prLength.text = "\(textLength)/\(vm.prMaxLength)"
        
        /*
        if textLength == 0 {
            textView.text = vm.prPlaceHolder
            textView.textColor = .systemGray
        }
        */
        
    }
}

// MARK: - RegStoragePictureCellDelegate
extension StoreVc: RegStoragePictureCellDelegate {
    func didCrop(croppedImg: UIImage) {
        insertPicture(img: croppedImg)
    }
    
    func deleted(seq: String) {
        vm.deleteStorePicture(attachSeq: seq) { (success, msg) in
            self.updatePictureCount()
            guard success else {
                let alert = _utils.createSimpleAlert(title: "매장 사진 삭제", message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
                return
            }
        }
        
    }
    
    func selectedMultipleImage(imgs: [UIImage]) {
        for img in imgs {
            insertPicture(img: img)
        }
    }
    
    func selectedImage(img: UIImage) {
        insertPicture(img: img)
    }
}

// MARK: - RegTimeDelegate
extension StoreVc: RegTimeDelegate {
    func timeSelected(time: String) {
        let timeIsValid = validateTime()
        open.updateStatus(valid: timeIsValid)
        close.updateStatus(valid: timeIsValid)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension StoreVc: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // dismiss picker
        picker.dismiss(animated: true)
        
        for result in results {
            let itemProvider = result.itemProvider
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {                      // provider가 내가 지정한 타입을 로드할 수 있는지 확인
                itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in      // load image
                    DispatchQueue.main.async {
                        if let img = image as? UIImage { self.insertPicture(img: img) }
                        else {
                            self.createSimpleAlert(title: _strings[.alertPictureSelectionErr], msg: error.debugDescription)
                        }
                    }
                }
            } else {
                // TODO: Handle empty results or item provider not being able load UIImage
            }
        }
        
        
        /*
         // 이미지를 하나 선택했을때 crop할 수 있도록 함
         var cropVc: CropViewController!
         if self.cropRectRatio > 0 {
             var config = Mantis.Config()
             config.ratioOptions = [.custom]
             config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: self.cropRectRatio)
             cropVc = Mantis.cropViewController(image: thumb, config: config)
         } else {
             cropVc = Mantis.cropViewController(image: thumb)
         }
         
         cropVc.delegate = self
         cropVc.modalPresentationStyle = .fullScreen
         self.present(cropVc, animated: true)
         */
    }
}




