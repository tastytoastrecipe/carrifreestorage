//
//  PopButton.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/01/13.
//

import UIKit

@objc protocol PopButtonDelegate {
    @objc optional func onTouch(_ sender: PopButton)
}

class PopButton: UIView {
    
    enum PopButtonType: Int {
        case save = 90
        case modify
        case cancel
        case refresh
        case back
        case none
    }
    
    struct SelectedStatus {
        var imgName: String
        var title: String
        var imgColor: UIColor
        var titleColor: UIColor
        var bgColor: UIColor
    }

    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    var delegate: PopButtonDelegate? = nil
    var xibLoaded: Bool = false
    var type: PopButtonType = .none
    var isSelected: Bool = false
    var hideBorder: Bool = false
    var deselectedStatus: SelectedStatus! = nil
    var selectedStatus: SelectedStatus! = nil
    
     
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    init(frame: CGRect, systemImgName: String, title: String, type: PopButtonType, imgColor: UIColor = .white, titleColor: UIColor = .white, bgColor: UIColor = _utils.symbolColorSemi, hideBorder: Bool) {
        super.init(frame: frame)
        loadXib()
        
        self.type = type
        self.hideBorder = hideBorder
//        img.image = UIImage(systemName: systemImgName)
//        img.tintColor = imgColor
//        self.title.text = title
//        self.title.textColor = titleColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTouch(_:)))
        bg.addGestureRecognizer(tapGesture)
        bg.layer.cornerRadius = frame.width / 2
//        bg.backgroundColor = bgColor
        
        deselectedStatus = SelectedStatus(imgName: systemImgName, title: title, imgColor: imgColor, titleColor: titleColor, bgColor: bgColor)
        selectedStatus = SelectedStatus(imgName: systemImgName, title: title, imgColor: imgColor, titleColor: titleColor, bgColor: bgColor)
        
        setSelected(selected: false)
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: PopButton.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func saveStatus(selected:Bool, systemImgName: String, title: String, imgColor: UIColor, titleColor: UIColor, bgColor: UIColor) {
        
        if selected {
            selectedStatus.imgName = systemImgName; selectedStatus.title = title; selectedStatus.imgColor = imgColor; selectedStatus.titleColor = titleColor; selectedStatus.bgColor = bgColor
        } else {
            deselectedStatus.imgName = systemImgName; deselectedStatus.title = title; deselectedStatus.imgColor = imgColor; deselectedStatus.titleColor = titleColor; deselectedStatus.bgColor = bgColor
        }
        
    }
    
    func setSelected(selected: Bool) {
        isSelected = selected
        
        var imgName: String = ""
        var title: String = ""
        var imgColor: UIColor!
        var titleColor: UIColor!
        var bgColor: UIColor!
        
        if selected {
            imgName = selectedStatus.imgName
            title = selectedStatus.title
            imgColor = selectedStatus.imgColor
            titleColor = selectedStatus.titleColor
            bgColor = selectedStatus.bgColor
        } else {
            imgName = deselectedStatus.imgName
            title = deselectedStatus.title
            imgColor = deselectedStatus.imgColor
            titleColor = deselectedStatus.titleColor
            bgColor = deselectedStatus.bgColor
        }
        
        img.image = UIImage(systemName: imgName)
        img.tintColor = imgColor
        
        self.title.text = title
        self.title.textColor = titleColor
        
        bg.backgroundColor = bgColor
        
        if false == hideBorder {
            bg.layer.borderWidth = 1
            bg.layer.borderColor = imgColor.cgColor
        }
        
    }
}

// MARK:- Actions
extension PopButton {
    @objc func onTouch(_ sender: UIGestureRecognizer) {
        setSelected(selected: !isSelected)
        delegate?.onTouch?(self)
    }
}

