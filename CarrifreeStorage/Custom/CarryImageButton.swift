//
//  CarryButton.swift
//  Carrifree
//
//  Created by orca on 2020/10/09.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit

protocol CarryImageButtonDelegate {
    func touchUp(button: CarryImageButton, isTapped: Bool)
}

class CarryImageButton: UIView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    @IBInspectable var isChoosible: Bool = true
    @IBInspectable var borderWidth: CGFloat = 4
    @IBInspectable var selectedColor: UIColor = _utils.symbolColorSoft
    @IBInspectable var selectedTextColor: UIColor = .white
    @IBInspectable var normalColor: UIColor = .white
    @IBInspectable var selectedImage: UIImage?
    @IBInspectable var normalImage: UIImage?
    
    var delegate: CarryImageButtonDelegate?
    var isTapped: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
                
        let touchUpGesture = UITapGestureRecognizer(target: self, action: #selector(self.touchUp(_:)))
        self.addGestureRecognizer(touchUpGesture)
        
        if isChoosible == false {
            let touchDownGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.touchDown(_:)))
            touchDownGesture.minimumPressDuration = 0
            
            self.addGestureRecognizer(touchDownGesture)
        
            // 하나의 view에서 여러개의 gesture를 받기위해 구현해야함 (UIGestureRecognizerDelegate)
            touchUpGesture.delegate = self
            touchDownGesture.delegate = self
        }
    }
    
    override func awakeFromNib() {
        setButton(isTapped: false)
    }
    
    private func setButton(isTapped: Bool) {
        if isTapped {
            self.backgroundColor = selectedColor
            if title != nil { title.textColor = selectedTextColor }
            if image != nil { image.image? = selectedImage ?? UIImage() }
            self.layer.borderWidth = 0
            
        } else {
            self.backgroundColor = .white
            if title != nil { title.textColor = normalColor }
            if image != nil { image.image? = normalImage ?? UIImage() }
            self.layer.borderWidth = borderWidth
            self.layer.borderColor = normalColor.cgColor
        }
    }
    
    func setTapped(isTapped: Bool) {
        if self.isTapped == isTapped { return }
        
        self.isTapped = isTapped
        setButton(isTapped: self.isTapped)
    }
    
    @objc func touchUp(_ sender: UIGestureRecognizer) {        
        if isChoosible {
            isTapped = !isTapped
            setButton(isTapped: isTapped)
        }
        else {
            setButton(isTapped: false)
        }
        
        delegate?.touchUp(button: self, isTapped: isTapped)
    }
    
    @objc func touchDown(_ sender: UIGestureRecognizer) {
        setButton(isTapped: true)
    }
}


// MARK:- UIGestureRecognizerDelegate
// 하나의 view에서 여러개의 gesture를 받기위해 구현해야함
extension CarryImageButton: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
