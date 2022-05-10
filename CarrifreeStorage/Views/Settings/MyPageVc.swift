//
//  MyPageController.swift
//  CarrifreeDriver
//
//  Created by plattics-kwon on 2021/07/08.
//

import UIKit
import Photos
import Mantis

class MyPageVc: UIViewController {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var profileCam: UIImageView!
    @IBOutlet weak var accountTitle: UILabel!
    
    @IBOutlet weak var id: TitleTextField!
    @IBOutlet weak var name: TitleTextField!
    @IBOutlet weak var email: TitleTextField!
    @IBOutlet weak var withdrawal: UIButton!
    
    var pwTimer:Timer? = nil
    var pwDelay: Double = 1.0
    var pwCheckTimer:Timer? = nil
    var pwCheckDelay: Double = 1.0
    
    var signUpManager: SignUpManager!
    var vm: MyPageVm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = _strings[.setMyInfo]
        self.navigationController?.navigationBar.tintColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
      
        vm = MyPageVm()
        setDefault()
        setDetail()
    }

    func setDefault() {
        profile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onProfile(_:))))
        profile.layer.cornerRadius = profile.frame.width / 2
        
        accountTitle.text = _strings[.memberInfo]
        
        id.configure(title: _strings[.id])
        id.setTextColor(color: .systemGray)
        id.setModifyEnable(enable: false)
        
        name.configure(title: _strings[.name])
        name.setTextColor(color: .systemGray)
        name.setModifyEnable(enable: false)
        
        email.configure(title: _strings[.eMail])
        email.setTextColor(color: .systemGray)
        email.setModifyEnable(enable: false)
        
        /*
        userCode.configure(title: _strings[.userCode])
        userCode.setTextColor(color: .systemGray)
        userCode.delegate = self
        
        pwTitle.text = _strings[.changePassword]
        pwDesc.text = "(\(_strings[.passwordRule]))"
        pwChange.setTitle(_strings[.changePassword], for: .normal)
        
        pw.configure(title: _strings[.pw])
        pw.isSecureTextEntry = true
        
        pwCheck.configure(title: _strings[.passwordCheck])
        pwCheck.isSecureTextEntry = true
        */
        
        setSignUpManager()
        setWithdrawal()
    }
    
    func setDetail() {
        setProfile()
        setId()
        setEmail()
        setName()
    }
    
    func setProfile() {
        vm.getProfilePicture() { (success, msg) in
            if success {
                if _user.profilePicture.url.isEmpty { return }
                let profileUrl = _user.profilePicture.url
                self.profile.loadImage(url: profileUrl)
            } else {
                self.createAlert(title: _strings[.requestFailed], msg: msg)
            }
        }
    }
    
    func setId() {
        if _user.signcase == .normal {
            id.text = _user.id
        } else {
            let socialAccountDesc = String(format: _strings[.socialAccountDesc], _user.signcase.name)
            id.text = socialAccountDesc
        }
    }
    
    func setEmail() {
        if _user.signcase == .normal {
            email.text = _user.email
        } else {
            email.removeFromSuperview()
        }
    }
    
    func setName() {
        name.text = _user.name
    }
    
    
    
    func setWithdrawal() {
        let normalAtt01: [NSAttributedString.Key: Any] = [
              .font: UIFont.systemFont(ofSize: 15),
              .foregroundColor: UIColor.systemBlue,
              .underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributeString01 = NSMutableAttributedString(string: _strings[.withdrawal], attributes: normalAtt01)
        withdrawal.setAttributedTitle(attributeString01, for: .normal)
    }
    
    func setSignUpManager() {
        signUpManager = SignUpManager()
    }
    
    func pwVerification(pw: String, completion: ((Bool, String) -> Void)?) {
        signUpManager.passwordVerification(pw: pw, completion: completion)
    }
    
    func registerProfilePicture(imgData: Data) {
        
        if false == _utils.createIndicator() { return }
        
        vm.registerProfilePicture(attachGrpSeq: _user.profilePicture.seq, imgData: imgData) { (success, msg) in
            _utils.removeIndicator()
            
            if success {
                self.createAlert(title: _strings[.registrationComplete], msg: "")
            } else {
                self.createAlert(title: _strings[.requestFailed], msg: msg)
            }
        }
    }
    
    func requestWithDrawal() {
        vm.requestWithDraw() { (success, msg) in
            if success {
                self.createAlert(title: _strings[.successToWithdrawal], msg: "", addCancel: false, completion: { (_) in
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                })
            } else {
                let alert = _utils.createSimpleAlert(title: _strings[.requestFailed], message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
            }
            
        }
    }
    
    func createAlert(title: String, msg: String, addCancel: Bool = false, completion: ((UIAlertController) -> Void)? = nil) {
        let ok = MyUtils.AlertHandler(title: _strings[.ok], handler: completion)
        let alert = _utils.createAlert(title: title, message: msg, handlers: [ok], style: .alert, addCancel: addCancel)
        _utils.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    func createSimpleAlert(title: String, msg: String, buttonTitle: String) {
        let alert = _utils.createSimpleAlert(title: title, message: msg, buttonTitle: buttonTitle)
        self.present(alert, animated: true)
    }
}

// MARK:- Actions
extension MyPageVc {
    @objc func onProfile(_ sender: UIGestureRecognizer) {
        let itemCamera = MyUtils.AlertHandler(title: _strings[.camera], handler: self.accessCamera)
        let itemAlbum = MyUtils.AlertHandler(title: _strings[.photoAlbum], handler: self.accessGallery)
        let alert = _utils.createAlert(handlers: [itemCamera, itemAlbum], style: .actionSheet)
        
        if let topVc = _utils.topViewController() {
            if UIDevice.current.userInterfaceIdiom == .pad { //디바이스 타입이 iPad일때
                if let popoverController = alert.popoverPresentationController { // ActionSheet가 표현되는 위치를 저장해줍니다.
                    popoverController.sourceView = topVc.view
                    popoverController.sourceRect = CGRect(x: topVc.view.bounds.midX, y: topVc.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                    topVc.present(alert, animated: true, completion: nil)
                }
            } else {
                topVc.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func onWithdrawal(_ sender: UIButton) {
        let ok = _utils.createAlertAction(title: _strings[.yes], handler: { (_) in
            self.requestWithDrawal()
        })
        
        let alert = _utils.createAlert(title: _strings[.withdrawal], message: _strings[.alertWithdrawal], handlers: [ok], style: .alert, addCancel: true)
        self.present(alert, animated: true)
    }
}

// MARK:- UIImagePickerControllerDelegate
extension MyPageVc: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        _utils.topViewController()?.present(picker, animated: true, completion: nil)
    }
    
    func openGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        _utils.topViewController()?.present(picker, animated: true, completion: nil)
    }
    
    // Camera 접근권한 확인
    func accessCamera(alertController: UIAlertController) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { status in
            if status {
                DispatchQueue.main.async { self.openCamera() }
            } else {}
        }
    }
        
    // Gallery 접근권한 확인
    func accessGallery(alertController: UIAlertController) {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .authorized {
            openGallery()
        } else {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    DispatchQueue.main.async { self.openGallery() }
                } else {}
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var tempThumb: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            tempThumb = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            tempThumb = originalImage
        }
        
        guard let thumb = tempThumb else { return }
        picker.dismiss(animated: false, completion: { () -> Void in
            var config = Mantis.Config()
            config.ratioOptions = [.custom]
            config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 10.0 / 10.0)
            
            let cropVc = Mantis.cropViewController(image: thumb, config: config)
            cropVc.delegate = self
            cropVc.modalPresentationStyle = .fullScreen
            self.present(cropVc, animated: true)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK:- CropViewControllerDelegate
extension MyPageVc: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: true, completion: nil)
        profile.image = cropped
        guard let imageData = cropped.jpegData(compressionQuality: 0.8) else {
            self.createAlert(title: _strings[.requestFailed], msg: "\(_strings[.alertFailedToRegisterPicture]) \(_strings[.plzTryAgain])")
            return
        }
        registerProfilePicture(imgData: imageData)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        print("crop canceled..")
    }
    
}
