//
//  RegPicture.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/25.
//

import UIKit
import Photos
import Mantis

@objc protocol RegPictureDelegate {
    @objc optional func registered(seq: String)
}

class RegPicture: UIView {

    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var mark: UIImageView!
    
    let cropRectRatio: Double = 1.0 / 1.0
    var delegate: RegPictureDelegate?
    var seq: String = ""
    var registered: Bool = false        // 이미지가 새로 등록되었는지 여부
    var xibLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: RegPicture.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onRegPicture(_:))))
    }
    
    func configure(title: String, desc: String, emptyImgName: String, imgUrl: String, seq: String = "") {
        configure()
        self.title.text = title
        self.title.font = UIFont(name: "NanumSquareR", size: 15)
        self.title.textColor = .darkGray
        self.title.layer.borderWidth = 1
        
        self.desc.text = desc
        self.desc.font = UIFont(name: "NanumSquareR", size: 11)
        self.desc.textColor = .darkGray
        
        if false == emptyImgName.isEmpty {
            var emptyImage = UIImage(systemName: emptyImgName)
            if nil == emptyImage { emptyImage = UIImage(named: emptyImgName) }
            emptyImg.image = emptyImage
        }
        
        self.seq = seq
        if let url = URL(string: imgUrl) {
            img.loadImage(url: url) {
                let registered = (self.img.image != nil)
                self.updateStatus(registered: registered)
            }
        } else {
            updateStatus(registered: false)
        }
        
    }
    
    func setImage(url: String, registered: Bool, seq: String) {
        if url.isEmpty { self.updateStatus(registered: registered); return }
        self.seq = seq
        img.loadImage(url: url) {
            let registeredImage = (self.img.image != nil)
            self.updateStatus(registered: registeredImage)
        }
    }
    
    func setImage(data: Data?, registered: Bool, seq: String) {
        guard let data = data else { self.updateStatus(registered: registered); return }
        self.seq = seq
        img.image = UIImage(data: data)
        updateStatus(registered: registered)
    }
    
    func setImage(image: UIImage?, registered: Bool, seq: String) {
        self.seq = seq
        img.image = image
        updateStatus(registered: registered)
    }
    
    func updateStatus(registered: Bool) {
        self.registered = registered
        if registered {
            self.title.layer.borderColor = UIColor(red: 152/255, green: 196/255, blue: 85/255, alpha: 1).cgColor
        } else {
            self.title.layer.borderColor = UIColor.systemGray.cgColor
        }
        
        mark.isHidden = !registered
    }
}

// MARK:- Actions
extension RegPicture {
    @objc func onRegPicture(_ sender: UIGestureRecognizer) {
        guard let topVc = _utils.topViewController() else { return }
        
        let itemCamera = MyUtils.AlertHandler(title: _strings[.camera], handler: self.accessCamera)
        let itemAlbum = MyUtils.AlertHandler(title: _strings[.photoAlbum], handler: self.accessGallery)
        let alert = _utils.createAlert(title: "", message: _strings[.alertNeedHorizontalPicture], handlers: [itemCamera, itemAlbum], style: .actionSheet)
        
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

// MARK:- UIImagePickerControllerDelegate
extension RegPicture: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
extension RegPicture: CropViewControllerDelegate {
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {}
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {}
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {}
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: true, completion: nil)
        
        img.image = cropped
        registered = true
        delegate?.registered?(seq: seq)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
