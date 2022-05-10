//
//  CarryButton.swift
//  Carrifree
//
//  Created by orca on 2020/10/09.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit

protocol CarryButtonDelegate {
    func touchUp(button: CarryButton, isTapped: Bool)
}

class CarryButton: UIButton {
    
    @IBInspectable var isChoosible: Bool = true
    @IBInspectable var borderWidth: Int = 2
    @IBInspectable var selectedColor: UIColor!
    @IBInspectable var diselectedColor: UIColor = .white
    
    var isTapped = false
    var delegate: CarryButtonDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        selectedColor = _utils.symbolColorSoft
        setButton(isTapped: false)
    }

    private func setButton(isTapped: Bool) {
        if isTapped {
            self.backgroundColor = selectedColor
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.clear.cgColor
            self.setTitleColor(diselectedColor, for: .normal)
        } else {
            self.backgroundColor = diselectedColor
            self.setTitleColor(selectedColor, for: .normal)
            self.layer.borderWidth = 2
            self.layer.borderColor = selectedColor.cgColor
        }
    }
    
    func setTapped(isTapped: Bool) {
        self.isTapped = isTapped
        setButton(isTapped: self.isTapped)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isChoosible == false {
            setButton(isTapped: true)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isChoosible {
            isTapped = !isTapped
            setButton(isTapped: isTapped)
        } else {
            setButton(isTapped: true)
        }
        
        delegate?.touchUp(button: self, isTapped: isTapped)
    }
}
