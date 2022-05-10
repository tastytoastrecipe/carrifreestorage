//
//  SettingsCtr.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/22.
//

import UIKit
import SafariServices

protocol SettingsVcDelegate {
    func settingVcDeleted()
}

class SettingsVc: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    enum MenuCase: String {
        case storeHidden
        case registrationInfo
        case storeInfo
        case myInfo
        case signOut
        case terms
        case contact
        case company
        case version
        
        var title: String {
            switch self {
            case .storeHidden: return _strings[.settingsSection01Menu01]
            case .registrationInfo: return _strings[.settingsSection02Menu01]
            case .storeInfo: return _strings[.settingsSection02Menu02]
            case .myInfo: return _strings[.settingsSection03Menu01]
            case .signOut: return _strings[.signOut]
            case .terms: return _strings[.settingsSection04Menu01]
            case .contact: return _strings[.settingsSection04Menu02]
            case .company: return _strings[.settingsSection04Menu03]
            case .version: return _strings[.settingsSection05]
            }
        }
    }
    
    typealias SettingsRow = (header: String, rows: [MenuCase])
    var dataSource: [SettingsRow] = []
    var delegate: SettingsVcDelegate?
    
    var hiddenSeg: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*

         보관사업자 활동
         ㄴ 매장정보
         
         사용자 설정
         ㄴ 사업자 정보 입력
         ㄴ 매장 정보 입력
         
         내정보
         ㄴ 정보 변경
         ㄴ 로그아웃
         
         고객센터
         ㄴ 약관
         ㄴ 문의하기
         ㄴ 회사소개
         
         버전 정보
         ㄴ live storage(I003) v1.0.38
         
        */
        
        self.navigationItem.title = _strings[.settings]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .white
        
        createBackButton()
        
        dataSource.append((_strings[.settingsSection01], [.storeHidden]))
        
        dataSource.append((_strings[.settingsSection02], [.registrationInfo, .storeInfo]))
        
//        dataSource.append((_strings[.settingsSection03], [.myInfo, .signOut]))
        dataSource.append((_strings[.settingsSection03], [.signOut]))
        
//        dataSource.append((_strings[.settingsSection04], [.terms, .contact, .company]))
        dataSource.append((_strings[.settingsSection04], [.contact, .company]))
        
        dataSource.append((_strings[.settingsSection05], [.version]))
        
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.sectionIndexColor = .white
        
        refresh()
    }
    
    func createBackButton() {
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backbutton.tintColor = UIColor(red: 242.0 / 255.0, green: 123.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
//        backbutton.setTitle("Back", for: .normal)
        backbutton.setTitleColor(backbutton.tintColor, for: .normal)
        backbutton.addTarget(self, action: #selector(self.onBack(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
    }
    
    // '매장 정보' cell 생성
    func createStorageInfoCell() -> UITableViewCell? {
        if dataSource.isEmpty { return nil }
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        cell.textLabel?.text = ""
        
        // segment
        let topSpace: CGFloat = 8
        let items = [_strings[.invisible], _strings[.visible]]
        hiddenSeg = UISegmentedControl(items: items)
        hiddenSeg.selectedSegmentIndex = 0
        hiddenSeg.addTarget(self, action: #selector(self.onSegmentValueChanged(_:)), for: .valueChanged)
//        activationSeg.selectedSegmentTintColor = UIColor(red: 255 / 255, green: 250 / 255, blue: 250 / 255, alpha: 1.0)
        cell.addSubview(hiddenSeg)
        
        hiddenSeg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hiddenSeg.topAnchor.constraint(equalTo: cell.topAnchor, constant: topSpace),
            hiddenSeg.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -8),
            hiddenSeg.widthAnchor.constraint(equalToConstant: 160),
            hiddenSeg.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // 세그먼트에서 선택된(움직이는) 뷰의 borderWidth와 border 컬러를 직접 바꿀수 없기때문에 그것을 표현할 view를 새로 생성함
        let selectedColor = UIColor(red: 152/255, green: 196/255, blue: 85/255, alpha: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)) {
            if self.hiddenSeg.numberOfSegments >= items.count {
                
                // 선택된 view 추출 (세그먼트의 개수와 일치하는 인덱스에 있음)
                let selectedSegIndex = items.count
                let selectedSeg = self.hiddenSeg.subviews[selectedSegIndex]
                
                // border를 표시할 view 생성
                let borderView = UIView(frame: CGRect(x: 4, y: 5, width: selectedSeg.frame.width - 8, height: selectedSeg.frame.height - 10))
                borderView.backgroundColor = .clear
                borderView.layer.cornerRadius = 6
                borderView.layer.borderWidth = 1
                borderView.layer.borderColor = selectedColor.cgColor
                self.hiddenSeg.subviews[selectedSegIndex].addSubview(borderView)
            }
        }
        
        // title
        let title = UILabel()
        title.text = _strings[.settingsSection01Menu01]
        title.font = UIFont(name: "NanumSquareR", size: 15)
        title.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(title)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: cell.topAnchor, constant: topSpace),
            title.trailingAnchor.constraint(equalTo: hiddenSeg.leadingAnchor, constant: 8),
            title.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // desc
        let desc = UILabel()
        desc.text = _strings[.visibleDesc]
        desc.textColor = .gray
        desc.font = UIFont(name: "NanumSquareR", size: 13)
        desc.numberOfLines = 0
        desc.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(desc)
        
        NSLayoutConstraint.activate([
            desc.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10),
            desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            desc.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
            desc.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -8)
        ])
        
        desc.baselineAdjustment = .alignCenters
        
        return cell
    }
    
    // '사업자 및 정산' cell 생성
    func createSettlementsCell() -> UITableViewCell? {
        if dataSource.isEmpty { return nil }
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        
        // title
        let topSpace: CGFloat = 8
        let title = UILabel()
        title.text = MenuCase.registrationInfo.title
        title.font = UIFont(name: "NanumSquareR", size: 15)
        title.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(title)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: cell.topAnchor, constant: topSpace),
            title.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            title.heightAnchor.constraint(equalToConstant: 36)
        ])
   
        // get approval state
        var approvalStr = "   \(_strings[.notApproved])   "
        let approvalState = _user.approval
        if approvalState == .approved { approvalStr = "   \(_strings[.approvalComplete])   " }
        
        // approval
        let approval = UILabel()
        approval.text = approvalStr
        approval.textColor = .white
        approval.font = UIFont(name: "NanumSquareR", size: 13)
        cell.addSubview(approval)
        
        let approvalHeight: CGFloat = 26
        approval.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            approval.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: 0),
            approval.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 10),
            approval.heightAnchor.constraint(equalToConstant: approvalHeight)
        ])
        
        approval.clipsToBounds = true
        approval.layer.cornerRadius = approvalHeight / 2
        approval.backgroundColor = .systemRed
        if approvalState == .approved { approval.backgroundColor = UIColor(red: 152/255, green: 196/255, blue: 85/255, alpha: 1) }

        return cell
    }
    
    
    // '버전 정보' cell 생성
    func createVersionCell() -> UITableViewCell? {
        if dataSource.isEmpty { return nil }
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        cell.textLabel?.text = _utils.getAppVersion()
//        cell.detailTextLabel?.text = "v1.0.38"
        
        // version
        let version = UILabel()
        version.text = _utils.getAppInfo()
        version.textColor = .systemRed
        version.font = UIFont(name: "NanumSquareR", size: 14)
        version.textAlignment = .right
        cell.addSubview(version)
        
        version.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            version.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: 0),
            version.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -20),
            version.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            version.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        return cell
    }
    
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
    
    func refresh() {
        // 노출/비노출 상태 갱신
        _cas.registration.getUserInfo() { (success, json) in
            guard let json = json else { return }
            
            let visibleStr = json["AVAILABLE_YN"].stringValue
            let hidden = !(visibleStr == "Y")
            
            if hidden {
                self.hiddenSeg.selectedSegmentIndex = 0
            } else {
                self.hiddenSeg.selectedSegmentIndex = 1
            }
        }
    }
    
    func exit() {
        self.navigationController?.view.removeFromSuperview()
        self.navigationController?.removeFromParent()
        delegate?.settingVcDeleted()
    }

}

// MARK:- Actions
extension SettingsVc {
    @objc func onBack(_ sender: UIButton) {
        exit()
    }
    
    @objc func onSegmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {       // 비노출
            setAppearance(appear: false)
        } else {                                    // 노출
            setAppearance(appear: true)
        }
    }
}

// MARK:- UITableView
extension SettingsVc: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
//        let heaerTitle = dataSource[indexPath.section].header
        let menuCell = dataSource[indexPath.section].rows[indexPath.row]
        
        if menuCell == .storeHidden {
            if let tempCell = createStorageInfoCell() { cell = tempCell }
        } else if menuCell == .registrationInfo {
            if let tempCell = createSettlementsCell() { cell = tempCell }
        } else if menuCell == .version {
            if let tempCell = createVersionCell() { cell = tempCell }
        } else {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
            cell.textLabel?.text = menuCell.title
        }
        
        if (menuCell == .storeHidden || menuCell == .version){
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        
        cell.textLabel?.font = UIFont(name: "NanumSquareR", size: 15)
        
        // 내용이 있는 cell에만 seperator 표시
        if indexPath.row < dataSource[indexPath.section].rows.count - 1 {
            let separatorWidth = self.view.frame.size.width - 20
            let separator = UIView(frame: CGRect(x: 10, y: cell.frame.size.height - 1, width: separatorWidth, height: 1))
            separator.backgroundColor = .systemGray6
            cell.addSubview(separator)
            
            separator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                separator.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 0),
                separator.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
                separator.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 20),
                separator.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = dataSource[indexPath.section].rows[indexPath.row]
        
        if cell == .storeHidden {
            return 120
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "NanumSquareB", size: 17)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = dataSource[indexPath.section].rows[indexPath.row]
        
        /*
         case storeHidden
         case registrationInfo
         case storeInfo
         case myInfo
         case signOut
         case terms
         case contact
         case company
         case version
         */
        
        if cell == .registrationInfo {
            let vc = RegistrationVc()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if cell == .storeInfo {
            _cas.general.getMainTapInfo() { (_, _) in
                if _user.approval == .approved {
                    let vc = StoreVc()
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
                
                let alert = _utils.createSimpleAlert(title: "사업자 정보 필요", message: "보관사업자 승인 요청을 완료해주시기 바랍니다.", buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
            }
        } else if cell == .myInfo {
            let vc = MyPageVc()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if cell == .signOut {
            _cas.signin.signout() { (success, _) in self.signOut() }
        } else if cell == .terms {
//            let vc = TermsVc()
//            self.navigationController?.pushViewController(vc, animated: true)
        } else if cell == .contact {
            UIPasteboard.general.string = _identifiers[.csEmail]
            let message = "\(_strings[.csAnnounce])\n(\(_strings[.copied]): \(_identifiers[.csEmail]))"
            let alert = _utils.createSimpleAlert(title: _strings[.settingsSection04Menu02], message: message, buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
        } else if cell == .company {
            guard let url = URL(string: _identifiers[.platticsHomepage]) else { return }
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)
        }
    }
    
    func signOut() {
        _user.removeData()
        
        let ok = MyUtils.AlertHandler(title: _strings[.ok]) { (_) in
            // 로그아웃 성공 후 RootViewController로 이동
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        }
        let alert = _utils.createAlert(title: _strings[.signOut], message: _strings[.signOutDone], handlers: [ok], style: .alert, addCancel: false)
        self.present(alert, animated: true, completion: nil)
    }
}

