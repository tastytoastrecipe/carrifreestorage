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
        
        // ?????????????????? ?????????(????????????) ?????? borderWidth??? border ????????? ?????? ????????? ??????????????? ????????? ????????? view??? ?????? ?????????
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)) {
            if self.hidden.numberOfSegments >= segTitles.count {
                
                // ????????? view ?????? (??????????????? ????????? ???????????? ???????????? ??????)
                let selectedSegIndex = segTitles.count
                let selectedSeg = self.hidden.subviews[selectedSegIndex]
                
                // border??? ????????? view ??????
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
//        categoryStatus.text = "?????? 1??? ?????? ??????????????? ?????????."
//        categoryStatus.font = descFont02
    }
    
    /*
     case enterStoreInfo = "???????????? ??????"
     case setVesible = "??????????????? ?????? ?????? ??????"
     case visible = "??????"
     case invisible = "?????????"
     case visibleDesc = "????????? ???????????? ??????????????? ????????? ????????? ?????? ?????????????????? ??????????????? ?????????????????? ????????? ???????????? ????????????."
     case registerStorePic = "??????????????? ??????????????????.(?????? 10???)"
     case registerStorePicDesc = "????????? ?????? ??????????????? ???????????????. ???????????? 1?????? ??????????????? ?????? ????????? ???????????? ??? ????????????."
     case registerStoreInfo = "???????????? ??????/??????"
     case registerWorkTime = "?????? ??????????????? ??????????????????."
     case opentime = "????????????"
     case closetime = "????????????"
     case enterPr = "?????? ???????????? ???????????????."
     case enterLuggagesTitle = "??? ????????? ?????? ???????????? ???????????????????"
     case enterLuggages = "?????? ????????? ??? ????????? ??????????????????"
     case wrongLuggages = "??? ?????? ????????? ???????????? ??????????????????."
     case ea = "???"
     case enterMerits = "?????? ????????? ???????????????."
     case emptyMerits = "?????? ????????? 1??? ?????? ??????????????????"
     case enterCosts = "??????????????? ??????????????????."
     case usingCarrifreeCosts = "???????????? ?????? ??????"
     case needDefaultSotrePic = "??????(??????) ????????? 1??? ?????? ??????????????????"
     case wrongWorktime = "?????? ????????? ???????????? ??????????????????"
     case wrongCosts = "????????? ???????????? ??????????????????."
     case registerStore = "???????????? ??????"
     case needPhotoAccessPermission = "?????? ?????? ????????? ???????????????. '??????'??? ???????????? ?????? ?????? ?????? ???????????? ???????????????."
     case alertPictureSelectionErr = "?????? ?????? ??????"
     
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
//        meritsStatus.text = "?????? 1??? ?????? ??????????????? ?????????."
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
    
    // ?????? ??????
    func insertPicture(img: UIImage) {
        // ???????????? cell ??? ???????????? ????????? ?????????
        for cell in pictureCells {
            if cell.isEmpty {
                cell.setImageWithImage(image: img, registered: true, seq: cell.seq)
                break
            }
        }
        
        updatePictureCount()
        updatePictureDesc()
    }
    
    /// ?????? ?????? text ??????
    func updatePictureCount() {
        
        var currentPictureCount: Int = 0
        for cell in pictureCells {
            if false == cell.isEmpty { currentPictureCount += 1 }
        }
        
        pictureCount.text = "\(currentPictureCount) / \(vm.maxPictureCount)"
    }
    
    // MARK: ????????? ?????? ??? ???????????? ??????
    func validateAndRegister() {
        self.view.endEditing(true)
        
        var isValid = true
        
        let pictureIsEmpty = pictureIsEmpty()
        updatePictureDesc()
        if pictureIsEmpty {
            _log.log("?????? ????????????!")                        // ?????? ????????????
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.needDefaultSotrePic])
            isValid = false
        }
        
        let timeIsValid = validateTime()
        open.updateStatus(valid: timeIsValid)
        close.updateStatus(valid: timeIsValid)
        if false == timeIsValid {
            _log.log("????????? ????????????!")                       // ????????? ?????? ??????
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.wrongWorktime])
            isValid = false
        }
        
        category.updateStatus(valid: category.isSelected, invalidString: _strings[.alertSelectStoreCategory])
//        categoryStatus.isHidden = category.isSelected
        if false == category.isSelected {
            _log.log("?????? ????????????!")                        // ?????? ????????????
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.alertSelectStoreCategory])
            isValid = false
        }
        
        let luggageCount = Int(luggage.text ?? "") ?? 0
        luggageStatus.isHidden = (luggageCount > 0)
        if luggageCount <= 0 {
            _log.log("??? ?????? ????????????!")                      // ??? ?????? ????????????
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.enterLuggages])
            isValid = false
        }

        merits.updateStatus(valid: category.isSelected, invalidString: _strings[.emptyMerits])
//        meritsStatus.isHidden = merits.isSelected
        if false == merits.isSelected {
            _log.log("?????? ?????? ????????????!")                     // ?????? ?????? ????????????
            self.createSimpleAlert(title: _strings[.settingsSection01Menu01], msg: _strings[.emptyMerits])
            isValid = false
        }
        
        let isValidCost = cost.isValid
        costStatus.isHidden = isValidCost
        cost.validate()
        if false == isValidCost {
            costStatus.text = _strings[.wrongCosts]
            _log.log("?????? ????????????!")                         // ?????? ????????????
            isValid = false
        }
        
        guard isValid else { return }
        
        // ????????? ?????????! (???????????? ??????)
        var allSuccess: Bool = false
        if false == _utils.createIndicator() { return }
        
        self.registerWorkTime() { (success) in if success == false { allSuccess = success }
            
        self.registerDayoff() { (success) in if success == false { allSuccess = success }       // ????????? ??????
        
        self.registerCategory() { (success) in if success == false { allSuccess = success }     // ?????? ??????
        
        self.registerMerits() { (success) in if success == false { allSuccess = success }       // ?????? ?????? ??????
        
        self.registerCost() { (success) in if success == false { allSuccess = success }         // ?????? ??????
        
        self.registerStoreInfo() { (success) in if success == false { allSuccess = success }    // ????????????, ????????? ??????
        
        self.writeStore() { (success, _) in if success == false { allSuccess = success }
        
        self.registerPictures() { (success) in if success == false { allSuccess = success }
            
        allSuccess = success
        _utils.removeIndicator()
        self.delegate?.registeredStore()
        if allSuccess { self.createSimpleAlert(title: "??????", msg: "??????????????? ?????????????????????") }
            
        }}}}}}}}
    }
    
    // ????????? ????????? ??????
    func validateTime() -> Bool {
        let startTime = open.getTime()
        let endTime = close.getTime()
        return startTime != endTime
    }
    
    // ????????? ??????????????? text ??????
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
    
    // ????????? ?????? ???????????? ???????????? ??????
    func pictureIsEmpty() -> Bool {
        var empty: Bool = true
        for cell in pictureCells {
            if cell.isEmpty == false { empty = false }
        }
        
        return empty
    }
    
    // MARK: ?????? ?????? ??????
    func registerPictures(completion: requestCallback = nil) {
        var isRegistered: Bool = false
        var mainPicture: Data? = nil
        var normalPictures: [Data?] = []
        for cell in pictureCells {
            guard cell.registered else { continue }     // ?????? ????????? ?????? ???
            isRegistered = true
            let imgData = cell.getImageData()
            if cell.isMain {                            // ?????? ?????????
                mainPicture = imgData
            } else {                                    // ?????? ????????? ?????????
                normalPictures.append(imgData)
            }
        }
        
        // ????????? ????????? ????????? ?????? ???????????? ?????? ????????? ????????? ????????? ???????????? ?????????
        if false == isRegistered { completion?(true); return }

        // ??????/?????? ?????? ?????? ??????
        vm.registerStorePicture(main: mainPicture, normal: normalPictures) { (success, msg) in
            if success {
                // ?????? ?????? ?????? ??????
                for cell in self.pictureCells { cell.registered = false }
            } else {
                self.createSimpleAlert(title: msg, msg: "")
            }
            
            completion?(success)
        }
    }
    
    // MARK: ????????? ??????
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
    
    // MARK: ???????????? ??????
    func registerWorkTime(completion: requestCallback = nil) {
        let openStr = "\(open.getTime())"
        let closeStr = "\(close.getTime())"
        vm.setWorktime(open: openStr, close: closeStr) { (success, msg) in
            if false == success { self.createSimpleAlert(title: msg, msg: "") }
            completion?(success)
        }
    }
    
    // MARK: ????????? ??????
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
    
    // MARK: ?????? ??????
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
    
    // MARK: ??? ?????? ?????? ??????
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
    
    // MARK: ?????? ?????? ??????
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
    
    // MARK: ?????? ??????
    func registerCost(completion: requestCallback = nil) {
        let defaultCostStrings = cost.getDefaultCostStrings()
        let extraCostStrings = cost.getExtraCostStrings()
        let dayCostStrings = cost.getDayCostStrings()
        vm.registerCosts(defaultCosts: defaultCostStrings, extraCosts: extraCostStrings, dayCosts: dayCostStrings) { (success, msg) in
            if false == success { self.createSimpleAlert(title: msg, msg: "") }
            completion?(success)
        }
    }
    
    // MARK: ?????? ??????(?????????, ?????? ??????) ??????
    /// ?????? ?????? ??????(?????????, ?????? ??????)
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
    
    // MARK: ?????? ?????? ?????? ??????
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
        if sender.selectedSegmentIndex == 0 {       // ?????????
            vm.setAppearance(appear: false)
        } else {                                    // ??????
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
//            createSimpleAlert(title: _strings[.storeInfo], msg: "??????????????? ?????????????????????")
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
                let alert = _utils.createSimpleAlert(title: "?????? ?????? ??????", message: msg, buttonTitle: _strings[.ok])
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
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {                      // provider??? ?????? ????????? ????????? ????????? ??? ????????? ??????
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
         // ???????????? ?????? ??????????????? crop??? ??? ????????? ???
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




