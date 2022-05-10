//
//  RegisterPictureView.swift
//  CarrifreeDriver
//
//  Created by plattics-kwon on 2021/03/24.
//

import UIKit
import Photos
import Mantis

@objc protocol RegisterPictureViewDelegate {
    @objc optional func registerPicture(imgData: Data?)
}

class RegisterPictureView: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var empty: UIImageView!
    @IBOutlet weak var desc: UILabel!
    
    var delegate: RegisterPictureViewDelegate? = nil
    var cropRectRatio: Double = -1.0        // crop rect 가로 x 세로 설정 (ex. 16:9 비율이면 16.0 / 9.0)
    var modifyEnable: Bool = true
    
    var alertTitle: String = ""
    var alertDesc: String = ""
    
    var xibLoaded: Bool = false
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: RegisterPictureView.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        setDefault()
    }
    
    func configure(img: UIImage?) {
        guard let image = img else { configure(); return }
        
        board.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSelected(_:))))
        empty.isHidden = true
        self.img.isHidden = false
        self.img.image = image
    }
    
    func configure(imgUrl: String) {
        board.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSelected(_:))))
        empty.isHidden = true
        self.img.isHidden = false
        self.img.loadImage(url: URL(string: imgUrl)!)
    }
    
    func setDefault() {
        board.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSelected(_:))))
        img.isHidden = true
        empty.isHidden = false
    }
    
    func setModifyEnable(enable: Bool) {
        modifyEnable = enable
        board.isUserInteractionEnabled = enable
    }
    
    func setImage(img: UIImage) {
        self.img.image = img
    }
    
    func setImage(url: String) {
        self.img.loadImage(url: url)
    }
    
    // crop rect 가로 x 세로 설정 (ex. 16:9 비율이면 16.0 / 9.0으로 보내면됨)
    func setCropRectRatio(ratio: Double) {
        cropRectRatio = ratio
    }
    
    func setDesc(desc: String) {
        self.desc.text = desc
    }
    
    func setAlertTitle(title: String, desc: String) {
        alertTitle = title; alertDesc = desc
    }
    
    func getImageData() -> Data? {
        return img.image?.jpegData(compressionQuality: 0.8)
    }
}

// MARK:- Actions
extension RegisterPictureView {
    @objc func onSelected(_ sender: UIGestureRecognizer) {
        guard modifyEnable else { return }

        let itemCamera = MyUtils.AlertHandler(title: _strings[.camera], handler: self.accessCamera)
        let itemAlbum = MyUtils.AlertHandler(title: _strings[.photoAlbum], handler: self.accessGallery)
        let alert = _utils.createAlert(title: alertTitle, message: alertDesc, handlers: [itemCamera, itemAlbum], style: .actionSheet)
        
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
}

// MARK:- UIImagePickerControllerDelegate
extension RegisterPictureView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        /*
        guard let thumb = tempThumb else { return }
        guard let newThumb = _utils.verticalImageCrop(img: thumb) else { return }
        img.image = newThumb
        self.reloadInputViews()
        picker.dismiss(animated: true, completion: nil)
        
        img.isHidden = false
        empty.isHidden = true
        delegate?.registerPicture?(imgData: newThumb.jpegData(compressionQuality: 0.8))
        */
        
        
        guard let thumb = tempThumb else { return }
        picker.dismiss(animated: false, completion: { () -> Void in
            
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
            _utils.topViewController()?.present(cropVc, animated: true)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK:- CropViewControllerDelegate
extension RegisterPictureView: CropViewControllerDelegate {
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        
    }
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: true, completion: nil)
        img.image = cropped
        self.reloadInputViews()
        
        img.isHidden = false
        empty.isHidden = true
        delegate?.registerPicture?(imgData: cropped.jpegData(compressionQuality: 0.8))
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
}

