//
//  RegisterStoragePictureCell.swift
//  CarrifreeStorage
//
//  Created by orca on 2021/01/01.
//

import UIKit
import Photos
import Mantis

@objc protocol RegisterPictureCellDelegate {
    @objc optional func registerPicture(imgData: Data?, index: Int)
    @objc optional func deletePicture(index: Int, id: String)
    @objc optional func onOpenCamera()
}


class RegisterPictureCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var exit: UIButton!
    @IBOutlet weak var desc: UILabel!
    
    var delegate: RegisterPictureCellDelegate? = nil
    var cropRectRatio: Double = -1.0        // crop rect 가로 x 세로 설정 (ex. 16:9 비율이면 16.0 / 9.0)
    var id: String = ""
    var index: Int = 0
    
    var alertTitle: String = ""
    var alertDesc: String = ""
    
    var configured: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func configure() {
        configured = true
        img.image = nil
        img.layer.borderWidth = 1
        img.layer.borderColor = UIColor.lightGray.cgColor
        img.layer.cornerRadius = 6
        exit.isHidden = true
    }
    
    func configure(imgData: Data?, index: Int, id: String) {
        if configured { return }
        
        self.index = index; self.id = id
        configure()
        setImage(imgData: imgData)
    }
    
    func configure(imgUrl: String, index: Int, id: String) {
        if configured { return }
        
        self.index = index; self.id = id
        configure()
        
        DispatchQueue.main.async {
            let imgData = _utils.getImageFromUrl(url: imgUrl)
            self.setImage(imgData: imgData)
        }
    }
    
    func setImage(imgData: Data?) {
        guard let data = imgData else { return }
        img.image = UIImage(data: data)
        
        exit.isHidden = (img.image == nil)
    }
    
    func onSelected(index: Int) {
        self.index = index
        
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
    
    func setDesc(desc: String, hidden: Bool, descBgColor: UIColor = UIColor(red: 161/255, green: 232/255, blue: 165/255, alpha: 1), textColor: UIColor = .white) {
        if hidden != self.desc.isHidden {
            self.desc.isHidden = hidden
            self.desc.text = "  \(desc)  "
            self.desc.backgroundColor = descBgColor
            self.desc.textColor = textColor
            self.desc.layer.cornerRadius = 6
        }
    }
    
    // crop rect 가로 x 세로 설정 (ex. 16:9 비율이면 16.0 / 9.0으로 보내면됨)
    func setCropRectRatio(ratio: Double) {
        cropRectRatio = ratio
    }
    
    func setAlertTitle(title: String, desc: String) {
        alertTitle = title; alertDesc = desc
    }
    
    func setExitHidden(hidden: Bool) {
        self.exit.isHidden = hidden
    }
    
    func delete() {
        if nil == img.image { return }
        
        img.image = nil
        exit.isHidden = true
        delegate?.deletePicture?(index: index, id: id)
    }
}

// MARK:- Actions
extension RegisterPictureCell {
    @IBAction func onDelete(_ sender: UIButton) {
        delete()
    }
}

// MARK:- 사진 선택, UIImagePickerControllerDelegate
extension RegisterPictureCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        delegate?.onOpenCamera?()
        
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
        
        delegate?.registerPicture?(imgData: newThumb.jpegData(compressionQuality: 0.8), index: index)
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
extension RegisterPictureCell: CropViewControllerDelegate {
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        
    }
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: true, completion: nil)
        exit.isHidden = false
        img.image = cropped
        self.reloadInputViews()
        delegate?.registerPicture?(imgData: cropped.jpegData(compressionQuality: 0.8), index: index)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
}
