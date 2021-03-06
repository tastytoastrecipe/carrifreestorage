//
//  VerificationVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/04.
//

import UIKit
import DropDown

class SignupVc: UIViewController {
    // navi
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var naviTitle: UILabel!
    
    // board
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var scrollview: UIScrollView!
    
    // terms
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var agreeAll: UIView!
    @IBOutlet weak var agreeAllIcon: UIImageView!
    @IBOutlet weak var agreeAllTitle: UILabel!
    @IBOutlet weak var termsStack: UIStackView!
    
    // phone
    @IBOutlet weak var phoneTitle: UILabel!
    @IBOutlet weak var countrycode: UILabel!
    @IBOutlet weak var country: UIView!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var requestAuth: UIButton!
    
    // auth
    @IBOutlet weak var doAuthView: UIView!
    @IBOutlet weak var limit: UILabel!
    @IBOutlet weak var doAuth: UIButton!
    @IBOutlet var pads: [BackwardTextField]!
    
    // id
    @IBOutlet weak var idView: UIView!
    @IBOutlet weak var idTitle: UILabel!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var idCheck: UIButton!
    @IBOutlet weak var idDesc: UILabel!
    @IBOutlet weak var idAvailable: UIButton!
    
    // name
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var nameField: UITextField!
    
    // pw
    @IBOutlet weak var pwView: UIView!
    @IBOutlet weak var pwTitle: UILabel!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var pwDesc: UILabel!
    @IBOutlet weak var pwEye: UIButton!
    
    // re-enter pw
    @IBOutlet weak var repwTitle: UILabel!
    @IBOutlet weak var repwField: UITextField!
    @IBOutlet weak var repwDesc: UILabel!
    @IBOutlet weak var repwEye: UIButton!
    
    // signup
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var signup: UIButton!
    @IBOutlet weak var signupDone: SignupDone!
    
    var vm: SignupVm!
    var isAgreeAll: Bool {
        get {
            var agreeAll: Bool = false
            for term in terms {
                guard term.data.required else { continue }
                agreeAll = term.agree
                guard agreeAll else { break }
            }
            
            return agreeAll
        }
    }
    var dropdown: DropDown! = nil
    var terms: [TermCell] = []
    var codeLevel = AuthCodeLevel.empty
    var codeWriting: Bool = false           // ???????????? ??????????????? ??????
    
    lazy var signupManager = SignUpManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        board.isHidden = true
        self.navigationItem.title = _strings[.signUp]
        
        vm = SignupVm(delegate: self)
        vm.requestTerms() { (success, msg) in
            if success {
                self.configure()
            } else {
                self.createSimpleAlert(msg: msg)
                self.dismiss()
            }
            
            self.board.isHidden = false
        }
    }
    
    // ????????? ???????????? ?????? view ?????? ??????
    @objc func keyboardWillShow() {
        if self.board.frame.origin.y < 0 { return }
        board.translatesAutoresizingMaskIntoConstraints = true
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.board.frame.origin.y -= 250
        })
    }

    // ????????? ???????????? ?????? view??? ?????? ????????? ??????
    @objc func keyboardWillHide() {
        if codeWriting { self.codeWriting = false; return }
        board.translatesAutoresizingMaskIntoConstraints = false
        UIView.animate(withDuration: 0.24, animations: { () -> Void in
            self.board.frame.origin.y += 250
        })
    }
    
    func configure() {
        
        _utils.setText(bold: .regular, size: 14, text: _strings[.signIn], button: back)
        back.addTarget(self, action: #selector(self.onBack(_:)), for: .touchUpInside)
        _utils.setText(bold: .extraBold, size: 17, text: _strings[.signUp], color: _symbolColor, label: naviTitle)
        _utils.setText(bold: .extraBold, size: 30, text: "?????? ?????? ??????", label: vcTitle)
        _utils.setText(bold: .regular, size: 20, text: "?????? ?????? ??????", label: agreeAllTitle)
        agreeAll.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onAgreeAll(_:))))
        
        var currentIndex: Int = 2
        vm.terms.forEach({
            let termCell = TermCell()
            termCell.configure(data: $0)
            termsStack.insertArrangedSubview(termCell, at: currentIndex)
            termCell.translatesAutoresizingMaskIntoConstraints = false
            termCell.heightAnchor.constraint(equalToConstant: 40).isActive = true
            termCell.setHeightCnst()
            termCell.delegate = self
            terms.append(termCell)
            currentIndex += 1
        })
        
        // phone
        _utils.setText(bold: .bold, size: 15, text: "????????? ??????", label: phoneTitle)
        _utils.setText(bold: .extraBold, size: 22, text: "", label: countrycode)
        phone.placeholder = "???-?????? ????????? ??????????????? ??????????????????"
        _utils.setText(bold: .extraBold, size: 22, text: "", field: phone)
        phone.addTarget(self, action: #selector(self.onEditPhoneBegin(_:)), for: .editingDidBegin)
        phone.addTarget(self, action: #selector(self.onEditPhoneEnd(_:)), for: .editingDidEnd)
        phone.addTarget(self, action: #selector(self.onEditPhone(_:)), for: .editingChanged)
        country.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onCountrycode(_:))))
        setDropdown()
        
        // auth
        requestAuth.layer.cornerRadius = requestAuth.frame.height / 2
        requestAuth.layer.borderColor = _symbolColor.cgColor
        requestAuth.layer.borderWidth = 1
        requestAuth.addTarget(self, action: #selector(self.onRequestAuth(_:)), for: .touchUpInside)
        _utils.setText(bold: .bold, size: 17, text: "???????????? ??????", color: _symbolColor, button: requestAuth)
        _utils.setText(bold: .bold, size: 15, text: "", label: limit)
        _utils.setText(bold: .bold, size: 17, text: "????????????", color: .white, button: doAuth)
        doAuth.addTarget(self, action: #selector(self.onDoAuth(_:)), for: .touchUpInside)
        for pad in pads {
            pad.addTarget(self, action: #selector(self.onEnterCode(_:)), for: .editingChanged)
            pad.addTarget(self, action: #selector(self.onEditCodeBegin(_:)), for: .editingDidBegin)
            pad.addTarget(self, action: #selector(self.onEditCodeEnd(_:)), for: .editingDidEnd)
            pad.backspaceCalled = self.onCodeBackspace
        }
        doAuthView.isHidden = true
        
        // id
        _utils.setText(bold: .regular, size: 20, text: "????????? ?????????", label: idTitle)
        _utils.setText(bold: .regular, size: 15, text: "", field: idField)
        idField.placeholder = "???????????? ??????????????????"
        _utils.setText(bold: .regular, size: 13, text: "?????? ??????", color: UIColor.systemGray, button: idCheck)
        idCheck.layer.cornerRadius = idCheck.frame.height / 2
        idCheck.layer.borderColor = UIColor.systemGray.cgColor
        idCheck.layer.borderWidth = 1
        idCheck.addTarget(self, action: #selector(self.onDuplicationCheck(_:)), for: .touchUpInside)
        _utils.setText(bold: .regular, size: 12, text: "", label: idDesc)
        _utils.setText(bold: .regular, size: 13, text: "?????? ??????", color: .white, button: idAvailable)
        idAvailable.layer.cornerRadius = idAvailable.frame.height / 2
        idAvailable.backgroundColor = _availableColor
        idAvailable.isHidden = true
        idView.isHidden = true
        
        // name
        _utils.setText(bold: .regular, size: 20, text: "??????", label: nameTitle)
        _utils.setText(bold: .regular, size: 15, text: "", field: nameField)
        nameField.placeholder = "????????? ????????? ?????????"
        nameView.isHidden = true
        
        // password
        _utils.setText(bold: .regular, size: 20, text: "????????????", label: pwTitle)
        _utils.setText(bold: .regular, size: 15, text: "", field: pwField)
        pwField.placeholder = _strings[.passwordRule]
        pwField.isSecureTextEntry = true
        pwField.addTarget(self, action: #selector(self.onPwChanged(_:)), for: .editingChanged)
        pwField.addTarget(self, action: #selector(self.onPwEditBegin(_:)), for: .editingDidBegin)
        pwField.addTarget(self, action: #selector(self.onPwEditEnd(_:)), for: .editingDidEnd)
        pwEye.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        pwEye.setImage(UIImage(systemName: "eye"), for: .selected)
        pwEye.addTarget(self, action: #selector(self.onPwEye(_:)), for: .touchUpInside)
        _utils.setText(bold: .regular, size: 12, text: "", label: pwDesc)
        pwView.isHidden = true
        
        // re-enter password
        _utils.setText(bold: .regular, size: 20, text: "????????????", label: repwTitle)
        _utils.setText(bold: .regular, size: 15, text: "", field: repwField)
        repwField.placeholder = "??????????????? ?????? ?????? ??????????????????"
        repwField.isSecureTextEntry = true
        repwField.addTarget(self, action: #selector(self.onPwChanged(_:)), for: .editingChanged)
        repwField.addTarget(self, action: #selector(self.onPwEditBegin(_:)), for: .editingDidBegin)
        repwField.addTarget(self, action: #selector(self.onPwEditEnd(_:)), for: .editingDidEnd)
        repwEye.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        repwEye.setImage(UIImage(systemName: "eye"), for: .selected)
        repwEye.addTarget(self, action: #selector(self.onRepwEye(_:)), for: .touchUpInside)
        _utils.setText(bold: .regular, size: 12, text: "", label: repwDesc)
        
        // sign up
        _utils.setText(bold: .bold, size: 19, text: _strings[.signUp], color: .white, button: signup)
        signup.addTarget(self, action: #selector(self.onSignup(_:)), for: .touchUpInside)
        signupView.isHidden = true
    }
    
    /// ?????? ?????? ??????
    func reverseAgreeAll() {
        let agree = isAgreeAll
        if agree {
            agreeAllIcon.image = UIImage(systemName: "checkmark.circle")
            agreeAllIcon.tintColor = .systemGray
            terms.forEach({ $0.setAgree(agree: false) })
            
        } else {
            agreeAllIcon.image = UIImage(systemName: "checkmark.circle.fill")
            agreeAllIcon.tintColor = _availableColor
            terms.forEach({ $0.setAgree(agree: true) })
        }
    }
    
    /// ?????? ?????? ?????? ??????
    func setDropdown() {
        guard nil == dropdown else { return }
        dropdown = DropDown()
        dropdown.dataSource = vm.countrycodes
        dropdown.anchorView = country
        dropdown.bottomOffset = CGPoint(x: 0, y: country.frame.height)
        dropdown.selectionAction = self.onSelect(index:item:)
        if vm.countrycodes.count > 0 { countrycode.text = vm.countrycodes[0] }
    }
    
    /// ?????? ?????? ?????? ??????
    func onSelect(index: Int, item: String) {
        guard index < vm.countrycodes.count else { return }
        
        dropdown.hide()
        countrycode.text = vm.countrycodes[index]
    }
    
    /// ???????????? ?????? ?????? ??????
    func checkConditions() -> Bool {
        // ?????? ?????? ??????
        if false == isAgreeAll {
            let alert = _utils.createSimpleAlert(title: "?????? ??????", message: "?????? ????????? ????????? ??? ??????????????????.", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return false
        }
        /*
        for termCell in terms {
            if termCell.data.required == false { continue }
            if false == termCell.agree {
                createSimpleAlert(msg: "?????? ????????? ?????????????????? ????????????.")
                return false
            }
        }
        */
        
        // ????????? ?????? ?????? ??????
        if true == phone.text?.isEmpty {
            createSimpleAlert(msg: "????????? ????????? ??????????????????")
            return false
        }
        
        // ????????? ?????? ??????
        guard vm.authComplete else {
            createSimpleAlert(msg: "????????? ????????? ??????????????????")
            return false
        }
        
        // ????????? ?????? ??????
        if true == idField.text?.isEmpty {
            createSimpleAlert(msg: _strings[.alertNeedId])
            return false
        }
        
        // ????????? ?????? ??????
        guard signupManager.isAvailableId(id: idField.text) else {
            createSimpleAlert(msg: _strings[.alertNeedIdDuplicationCheck])
            return false
        }
        
        // ?????? ?????? ??????
        if true == nameField.text?.isEmpty {
            createSimpleAlert(msg: _strings[.alertNeedName])
            return false
        }
        
        // ???????????? ?????? ??????
        if true == pwField.text?.isEmpty {
            createSimpleAlert(msg: _strings[.alertNeedPw])
            return false
        }
        
        // ???????????? ????????? ??????
        if true == repwField.text?.isEmpty {
            createSimpleAlert(msg: _strings[.alertNeedPw])
            return false
        }
        
        guard signupManager.pwAvailable else {
            createSimpleAlert(msg: _strings[.alertUnavailablePw])
            return false
        }
        
        return true
    }
    
    /// ???????????? ?????? ?????? ?????????/????????????
    func changeEye(btn: UIButton, field: UITextField) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected { btn.tintColor = _availableColor }
        else { btn.tintColor = .systemGray }
        
        field.isSecureTextEntry = !btn.isSelected
    }
    
    /// ???????????? ?????? ?????? ??????
    @objc func displayPwStatus() {
        let pwText = pwField.text ?? ""; if pwText.isEmpty { return }
        
        signupManager.passwordVerification(pw: pwText) { (available, msg) in
            if available { self.pwDesc.textColor = _availableColor }
            else { self.pwDesc.textColor = .red }
            self.pwDesc.text = msg
        }
    }
    
    /// ???????????? ???????????? ?????? ?????? ??????
    @objc func displayRepwStatus() {
        let pwText = pwField.text ?? ""; if pwText.isEmpty { return }
        let repwText = repwField.text ?? ""; if repwText.isEmpty { return }
        
        if signupManager.passwordCompare(pw01: pwText, pw02: repwText) {
            repwDesc.text = ""
        } else {
            repwDesc.textColor = .red
            repwDesc.text = _strings[.alertPwNotMatch]
        }
    }
    
    /// id ???????????? ??? ???????????? ?????? text??? alpha?????? animate
    func animateIdDesc() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.idDesc.alpha = 1
        })
    }
    
    func createSimpleAlert(msg: String) {
        let alert = _utils.createSimpleAlert(title: _strings[.signUp], message: msg, buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
    
    func dismiss() {
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
}

// MARK: - Actions
extension SignupVc {
    
    @objc func onBack(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false)
    }
    
    @objc func onAgreeAll(_ sender: UIGestureRecognizer) {
        reverseAgreeAll()
    }
    
    @objc func onCountrycode(_ sender: UIGestureRecognizer) {
        dropdown.show()
    }
    
    @objc func onEditPhoneBegin(_ sender: UITextField) {
        keyboardWillShow()
    }
    
    @objc func onEditPhoneEnd(_ sender: UITextField) {
        keyboardWillHide()
    }
     
    @objc func onEditPhone(_ sender: UITextField) {
        self.vm.authComplete = false
        
        // ???????????? ?????? ???????????? ?????? ?????? ?????? UI??? ?????????
        if sender.text?.isEmpty == true {
            vm.stopAuthTimer()
//            authView.isHidden = false
//            signinView.isHidden = true
        }
    }
    
    @objc func onRequestAuth(_ sender: UIButton) {
        // ?????? ?????? ??????
        guard isAgreeAll else {
            let alert = _utils.createSimpleAlert(title: "?????? ??????", message: "?????? ????????? ????????? ??? ??????????????????.", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return
        }
        
        // ?????? ?????? ??????
        if vm.authTime > 0 {
            let alert = _utils.createSimpleAlert(title: "????????? ??????", message: "????????? ????????? ????????? ?????? ?????? ?????? ??????????????????.", buttonTitle: _strings[.ok])
            self.present(alert, animated: true)
            return
        }
        
        // ????????? ?????? ?????? ??????
        guard let phoneStr = phone.text, false == phoneStr.isEmpty else {
            createSimpleAlert(msg: "????????? ????????? ??????????????????.")
            return
        }
        self.view.endEditing(true)
        
        vm.requestAuth(phone: phoneStr) { (success, msg) in
            if success {
                if sender.layer.borderColor != UIColor.systemGray.cgColor {
                    sender.layer.borderColor = UIColor.systemGray.cgColor
                    sender.setTitle("???????????? ?????????", for: .normal)
                    sender.setTitleColor(.systemGray, for: .normal)
                }
                
                self.doAuthView.isHidden = false
                self.vm.inAutheticating = true
                self.vm.startAuthTimer()
                self.scrollview.scroll(to: .bottom)
            } else {
                self.createSimpleAlert(msg: msg)
            }
        }
        
    }
    
    // ???????????? ?????? ??????
    @objc func onEditCodeBegin(_ sender: UITextField) {
        keyboardWillShow()
        if sender == phone { return }
        
        let text = sender.text ?? ""
        if text.count > 0 {
            codeLevel = AuthCodeLevel.filled
        } else {
            codeLevel = AuthCodeLevel.empty
        }
    }
    
    // ???????????? ?????? ??????
    @objc func onEditCodeEnd(_ sender: UITextField) {
        keyboardWillHide()
    }
    
    // ?????? ?????? ??????
    @objc func onEnterCode(_ sender: UITextField) {
        let text = sender.text ?? ""
        let textCount = text.count
        
        // ???????????? ???????????? ???
        if textCount > 1 {
            let result = String(text[text.startIndex])
            sender.text = result
        }
        
        // ???????????? ???????????? ????????????(????????????)?????? ???????????? ?????????????????????
        if textCount == 0 { codeLevel = AuthCodeLevel.removed; return }
        codeLevel = AuthCodeLevel.filled
        
        // ????????? ?????????????????? ???????????? TextField??? ???????????? ????????????
        for (index, pad) in pads.enumerated() {
            let nextIndex = index + 1
            if pad == sender && nextIndex < pads.count {
                codeWriting = true
                pads[nextIndex].becomeFirstResponder()
            }
        }
    }
    
    // Backspace ?????? ????????? ?????????
    func onCodeBackspace(sender: BackwardTextField) {
        // ????????? ??????????????? ????????? ????????? ???????????? ????????? TextField??? ???????????? ????????????
        guard codeLevel == .empty else {
            if codeLevel == .removed { codeLevel = .empty }
            return
        }
        
        for (index, pad) in pads.enumerated() {
            let prevIndex = index - 1
            if pad == sender && prevIndex > -1 {
                codeWriting = true
                pads[prevIndex].becomeFirstResponder()
            }
        }
    }
    
    @objc func onDoAuth(_ sender: UIButton) {
        guard let phoneStr = phone.text, false == phoneStr.isEmpty else {
            createSimpleAlert(msg: "????????? ????????? ??????????????????.")
            return
        }
        
        // ???????????? ?????? ??????
        var authCode: String = ""
        for pad in pads {
            let padText = pad.text ?? ""
            if padText.isEmpty {
                createSimpleAlert(msg: "??????????????? ?????? ??????????????????")
                return
            } else {
                authCode.append(contentsOf: padText)
            }
        }
        
        // ?????? api ?????? ??? ?????? ?????? ?????? ??????
        vm.doAuth(phone: phoneStr, authNo: authCode) { (success, msg) in
            guard success else { self.createSimpleAlert(msg: msg); return }
            
            self.view.endEditing(true)
            
            self.vm.stopAuthTimer()
            self.vm.inAutheticating = false
            self.vm.authComplete = true
            self.limit.isHidden = true
            
            self.doAuth.setTitleColor(_availableColor, for: .normal)
            self.doAuth.backgroundColor = .white
            self.doAuth.layer.borderColor = _availableColor.cgColor
            self.doAuth.layer.borderWidth = 1
            
            self.idView.isHidden = false
            self.nameView.isHidden = false
            self.pwView.isHidden = false
            self.signupView.isHidden = false
            
            self.scrollview.scroll(to: .center)
        }
    }
    
    /// ?????? ??????
    @objc func onDuplicationCheck(_ sender: UIButton) {
        let userId = idField.text ?? ""
        if userId.isEmpty { return }
        
        if userId.count < signupManager.minIdLength {
            createSimpleAlert(msg: _strings[.alertIdLengthMin])
            return
        }
        
        self.idDesc.alpha = 0
        vm.isAvailableId(id: userId) { (success, msg) in
            if success {
                self.idDesc.text = _strings[.alertAvailableId]
                self.idDesc.textColor = _availableColor
                self.signupManager.checkedIds.append(userId)
                self.signupManager.currentId = userId
            } else {
                self.idDesc.text = msg
                self.idDesc.textColor = .red
            }
            
            self.idAvailable.isHidden = !success
            self.animateIdDesc()
        }
    }
    
    /// ???????????? ??????/?????????
    @objc func onPwEye(_ sender: UIButton) {
        changeEye(btn: sender, field: pwField)
    }
    
    @objc func onRepwEye(_ sender: UIButton) {
        changeEye(btn: sender, field: repwField)
    }
    
    @objc func onPwChanged(_ sender: UITextField) {
        if (sender === pwField) {
            vm.startPwDelay()
            displayRepwStatus()
        } else if (sender === repwField) {
            vm.startRepwDelay()
        }
    }
    
    @objc func onPwEditBegin(_ sender: UITextField) {
        keyboardWillShow()
    }
    
    @objc func onPwEditEnd(_ sender: UITextField) {
        keyboardWillHide()
    }
    
    @objc func onSignup(_ sender: UIButton) {
        let signupAvailable = checkConditions()
        guard signupAvailable else { return }
        
        let phoneStr = phone.text ?? ""
        let nameStr = nameField.text ?? ""
        vm.signup(id: signupManager.currentId, pw: signupManager.currentPw, phone: phoneStr, name: nameStr) { (success, msg) in
            if success {
                self.signupDone.isHidden = false
                self.signupDone.configure(id: self.signupManager.currentId, pw: self.signupManager.currentPw, name: nameStr, phone: phoneStr)
                self.view.bringSubviewToFront(self.signupDone)
                
            } else {
                self.createSimpleAlert(msg: msg)
            }
            
        }
    }
}

// MARK: - TermCellDelegate
extension SignupVc: TermCellDelegate {
    func spreaded(cell: TermCell) {
        for subview in termsStack.arrangedSubviews {
            if subview === cell { continue }
            guard let termCell = subview as? TermCell else { continue }
            termCell.isSpreaded = false
        }
    }
}

// MARK: - SigninVmDelegate
extension SignupVc: SignupVmDelegate {
    func printTime(time: String) {
        limit.text = "???????????? \(time)"
    }
    
    func pwDelayed() {
        displayPwStatus()
    }
    
    func repwDelayed() {
        displayRepwStatus()
    }
}

/*
class SignupVc: UIViewController {
    
    @IBOutlet weak var complete: SignupDone!
    @IBOutlet weak var failed: UIView!
    @IBOutlet weak var failedDesc: UILabel!
    @IBOutlet weak var verification: UIButton!
    @IBOutlet weak var back: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _utils.setText(bold: .regular, size: 17, text: "??????????????? ???????????? ???????????????. ??????????????? ?????? ?????????????????? ??????????????? ???????????????.", label: failedDesc)
        _utils.setText(bold: .regular, size: 17, text: "????????????", button: verification)
        verification.backgroundColor = .white
        verification.layer.cornerRadius = (verification.frame.height - 2) / 2
        verification.layer.borderWidth = 1
        verification.layer.borderColor = UIColor(red: 120/255, green: 120/255, blue: 120/255, alpha: 1).cgColor
        verification.layer.shadowOffset = CGSize(width: 2, height: 2)
        verification.layer.shadowRadius = 1
        verification.layer.shadowOpacity = 0.2
        verification.addTarget(self, action: #selector(self.onVerification(_:)), for: .touchUpInside)
        back.addTarget(self, action: #selector(self.onBack(_:)), for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { self.verificate() }
    }
    
    func verificate() {
        let vc = ImpVerificationVc()
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        self.present(vc, animated: true)
    }
}

// MARK: - Actions
extension SignupVc {
    @objc func onBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc func onVerification(_ sender: UIButton) {
        failed.isHidden = true
        back.isHidden = true
        complete.isHidden = true
        verificate()
    }
}

// MARK: - ImpVerificationDelegate
extension SignupVc: ImpVerificationDelegate {
    func disappear() {
        let phone = ImpRequest.shared.phone
        failed.isHidden = !phone.isEmpty
        back.isHidden = !phone.isEmpty
        complete.isHidden = phone.isEmpty
        guard phone.count > 0 else { return }
        
        _log.logWithArrow("????????? ???????????? ??????!", phone)
        complete.configure(id: "M20000000001", name: "??????", phone: phone)
        complete.isHidden = false
    }
}
*/
