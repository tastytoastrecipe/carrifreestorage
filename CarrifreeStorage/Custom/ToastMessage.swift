//
//  ToastMessage.swift
//  Carrifree
//
//  Created by orca on 2020/10/22.
//  Copyright © 2020 plattics. All rights reserved.
//

import UIKit

class ToastMessage: UIView {
    
    enum Side {
        case top
        case bottom
        case center
    }
    
    static let toastTag: Int = 1113
    
    let widthVariable: CGFloat = 0.9        // 넓이를 정하는 기준 (화면 넓이 * widthVariable)
    let height: CGFloat = 60                // 높이
    let verticalInset: CGFloat = 15         // top, bottom과의 간격
    var displayingTime: Double = 3.0        // 화면에 보여지는 시간
    var isMoving: Bool = false
    var message: UILabel!
    var side: Side = .top {                 // 화면에서 표시되는 위치
        didSet {
            self.frame = getTargetFrame(appear: false)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(side: ToastMessage.Side, message: String) {
        self.side = side
        self.message = UILabel()
        super.init(frame: CGRect.zero)
        self.frame = getTargetFrame(appear: false)
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray5.cgColor
        self.layer.cornerRadius = 10//self.height / 2
        self.tag = ToastMessage.toastTag
        
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowRadius = 1.5
        self.layer.shadowOpacity = 0.2
        
        
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: 8).cgPath
        self.layer.shouldRasterize = true
        
        
        self.message.frame = CGRect(x: 8, y: 8,
                                    width: self.frame.width - 16,
                                    height: self.frame.height - 16)
        self.message.textColor = .systemGray
        self.message.textAlignment = .center
        self.message.font = UIFont.systemFont(ofSize: 22)
        addSubview(self.message)
    }
    
    func getTargetFrame(appear: Bool) -> CGRect {
        let screenSize = UIScreen.main.bounds.size
        let toastSize = CGSize(width: UIScreen.main.bounds.width * widthVariable, height: height)
        var toastPos = CGPoint(x: (screenSize.width - toastSize.width) / 2, y: 0)
        
        switch side {
        case.top:
            if appear { toastPos.y = height + verticalInset }
            else      { toastPos.y = -height }
        case.bottom:
            if appear { toastPos.y = screenSize.height - height - verticalInset }
            else      { toastPos.y = screenSize.height + height }
            
        case.center:
            toastPos.y = (screenSize.height / 2) - (height / 2)
        }
        
        let toastFrame = CGRect(x: toastPos.x, y: toastPos.y, width: toastSize.width, height: toastSize.height)
        return toastFrame
    }
    
    func appear(message: String = "") {
        self.message.text = message
        if isMoving { return }
        isMoving = true
        
        UIView.animate(withDuration: 0.4, animations: {
            self.frame = self.getTargetFrame(appear: true)
        }, completion: { done in
            DispatchQueue.main.asyncAfter(deadline: .now() + self.displayingTime) {
                self.isMoving = false
                self.hide()
            }
        })
    }
    
    func hide() {
        if isMoving { return }
        isMoving = true
        
        UIView.animate(withDuration: 0.4, animations: {
            self.frame = self.getTargetFrame(appear: false)
        }, completion: { done in
            self.isMoving = false
        })
    }

}
