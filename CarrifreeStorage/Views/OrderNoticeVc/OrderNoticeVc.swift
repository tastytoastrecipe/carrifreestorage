//
//  OrderNoticeVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/08.
//

import UIKit

@objc protocol OrderNoticeVcDelegate {
    @objc optional func onContinue()
    @objc optional func onExitWithRegistration()
    @objc optional func onExit()
}

class OrderNoticeVc: UIViewController {
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var boardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitBtn: UIButton!
    
    @IBOutlet weak var requiredTitle: UILabel!
    @IBOutlet weak var requiredDesc: UILabel!
    @IBOutlet weak var requiredBtn: UIButton!
    
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var continueView: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    var delegate: OrderNoticeVcDelegate!
    var status: String = ""                 // 의뢰 진행 상태 (OrderStatus)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateBoard()
        updateNotice(status: status)
    }
    
    func configure() {
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe(_:)))
        swipeGesture.numberOfTouchesRequired = 1
        swipeGesture.direction = .down
        self.view.addGestureRecognizer(swipeGesture)
        self.view.isUserInteractionEnabled = true
        
        // title
        requiredTitle.text = ""
        requiredTitle.numberOfLines = 0
        
        // desc
        requiredDesc.text = _strings[.needRegisterBiz]
        requiredDesc.numberOfLines = 0
        requiredDesc.font = UIFont(name: "NanumSquareB", size: 14)
        requiredDesc.textColor = .systemGray
        
        // button
        requiredBtn.setTitle(_strings[.moveToRegistration], for: .normal)
        requiredBtn.titleLabel?.font = UIFont(name: "NanumSquareB", size: 16)
        requiredBtn.addTarget(self, action: #selector(self.onBtn(_:)), for: .touchUpInside)
        
        // exit
        exitBtn.setTitle("", for: .normal)
        exitBtn.titleLabel?.font = UIFont(name: "NanumSquareB", size: 16)
        exitBtn.addTarget(self, action: #selector(self.onExit(_:)), for: .touchUpInside)
        
        // cancel
        cancelBtn.setTitle(_strings[.backToContent], for: .normal)
        cancelBtn.titleLabel?.font = UIFont(name: "NanumSquareB", size: 16)
        cancelBtn.addTarget(self, action: #selector(self.onExit(_:)), for: .touchUpInside)
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = cancelBtn.tintColor.cgColor
        
        // continue
        continueBtn.layer.borderWidth = 1
        continueBtn.layer.borderColor = continueBtn.tintColor.cgColor
        continueBtn.addTarget(self, action: #selector(self.onContinue(_:)), for: .touchUpInside)
    }
    
    /// [OrderStatus]에 따라 표시될 UI 갱신
    func updateNotice(status: String) {
        let orderStatus = OrderStatus(rawValue: status)
        
        if nil == orderStatus {
            // localization
            let attributedString = NSMutableAttributedString(string: _strings[.notYetDesc], attributes: [
              .font: UIFont(name: "NanumSquareR", size: 24)!,
              .foregroundColor: UIColor(white: 0.0, alpha: 1.0)
            ])
            attributedString.addAttributes([
              .font: UIFont(name: "NanumSquareB", size: 24)!,
              .foregroundColor: UIColor(red: 242.0 / 255.0, green: 123.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 6, length: 6))
            
            requiredTitle.attributedText = attributedString
            
            requiredDesc.text = _strings[.needRegisterBizDesc]
            
            requiredBtn.isHidden = false
            
            continueView.isHidden = true
            
            img.image = UIImage(named: "icon-cloud")
            
        } else if orderStatus == .purchased {
            // localization
            let attributedString = NSMutableAttributedString(string: _strings[.askOrderCheck], attributes: [
              .font: UIFont(name: "NanumSquareR", size: 24)!,
              .foregroundColor: UIColor(white: 0.0, alpha: 1.0)
            ])
            attributedString.addAttributes([
              .font: UIFont(name: "NanumSquareEB", size: 24)!,
              .foregroundColor: UIColor(red: 242.0 / 255.0, green: 123.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 5, length: 8))
            
            requiredTitle.attributedText = attributedString
            
            requiredDesc.text = _strings[.needOrderCheck]

            requiredBtn.isHidden = true

            continueView.isHidden = false
            
            continueBtn.setTitle(_strings[.goOrder], for: .normal)
            
            img.image = UIImage(named: "img-doc-1")
            
        } else if orderStatus == .entrust {
            // localization
//            let attributedString = NSMutableAttributedString(string: _strings[.askOrderCheck], attributes: [
//              .font: UIFont(name: "NanumSquareEB", size: 24)!,
//              .foregroundColor: UIColor(red: 242.0 / 255.0, green: 123.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
//            ])
//            attributedString.addAttributes([
//              .font: UIFont(name: "NanumSquareR", size: 24)!,
//              .foregroundColor: UIColor(white: 0.0, alpha: 1.0)
//            ], range: NSRange(location: 0, length: 5))
//            attributedString.addAttributes([
//              .font: UIFont(name: "NanumSquareR", size: 24)!,
//              .foregroundColor: UIColor(white: 0.0, alpha: 1.0)
//            ], range: NSRange(location: 15, length: 5))
            
//            requiredTitle.attributedText = attributedString
            _utils.setText(bold: .bold, size: 24, text: _strings[.askOrderCheck], label: requiredTitle)
            
            requiredDesc.text = _strings[.needOrderCheck]
            
            requiredBtn.isHidden = true
            
            continueView.isHidden = false
            
            continueBtn.setTitle(_strings[.orderDone], for: .normal)
            
            img.image = UIImage(named: "img-doc-2")
        }
        
    }
    
    func animateBoard() {
        board.frame.origin.y = self.view.frame.height
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.board.frame.origin.y = (self.view.frame.height - self.boardHeightConstraint.constant)
        })
    }
    
    func exit() {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true)
        self.delegate?.onExit?()
    }
    
}

// MARK: Actions
extension OrderNoticeVc {
    @objc func onBtn(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) {
            self.delegate?.onExitWithRegistration?()
        }
    }
    
    @objc func onExit(_ sedner: UIButton) {
        exit()
    }
    
    @objc func onSwipe(_ sender: Any) {
        exit()
    }
    
    @objc func onContinue(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) {
            self.delegate?.onContinue?()
        }
    }
}
