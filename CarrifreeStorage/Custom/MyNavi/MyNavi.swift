//
//  MyNavi.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/20.
//

import UIKit

@objc protocol MyNaviDelegate {
    @objc optional func tapApproval()
    @objc optional func tapInfo()
    @objc optional func tapSetting()
    @objc optional func tapNoti()
}

class MyNavi: UIView {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var approvalBoard: UIView!
    @IBOutlet weak var approvalNotYet: UIPaddingLabel!
    @IBOutlet weak var approvalDone: UIImageView!
    @IBOutlet weak var info: UIButton!
    @IBOutlet weak var setting: UIButton!
    @IBOutlet weak var noti: UIButton!
    @IBOutlet weak var stick: UIView!           // 아래 부분만 그림자 효과를 주기위한 뷰

    var delegate: MyNaviDelegate?
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
        guard let view = self.loadNib(name: String(describing: MyNavi.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        // board
        board.layer.borderWidth = 1
        board.layer.borderColor = UIColor.systemGray6.cgColor
        
        // shadow
        stick.layer.shadowOffset = CGSize(width: 0, height: 0)
        stick.layer.shadowRadius = 4
        stick.layer.shadowOpacity = 0.3
        
        // title
        title.text = "user name"
        
        // approval
        approvalNotYet.inset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        approvalNotYet.text = "미승인"
        approvalNotYet.backgroundColor = .systemRed
        approvalNotYet.textColor = .white
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.approvalNotYet.clipsToBounds = true
            let cornerRadius = self.approvalNotYet.frame.height / 2
            self.approvalNotYet.layer.cornerRadius = cornerRadius
        }
        
        // approval
        approvalBoard.isUserInteractionEnabled = true
        approvalBoard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onApproval(_:))))
        
        // info
        info.addTarget(self, action: #selector(self.onInfo(_:)), for: .touchUpInside)
        
        // setting
        setting.addTarget(self, action: #selector(self.onSetting(_:)), for: .touchUpInside)
        
        // noti
        noti.addTarget(self, action: #selector(self.onNoti(_:)), for: .touchUpInside)
    }
    
    func setName(name: String) {
        self.title.text = name
    }
    
    func setApproval(approval: ApprovalStatus) {
        let approved = approval == .approved
        approvalNotYet.isHidden = approved
        approvalDone.isHidden = !approved
    }

}

// MARK:- Actions
extension MyNavi {
    @objc func onApproval(_ sender: UIGestureRecognizer) {
        delegate?.tapApproval?()
    }
    
    @objc func onInfo(_ sender: UIButton) {
        delegate?.tapInfo?()
    }
    
    @objc func onSetting(_ sender: UIButton) {
        delegate?.tapSetting?()
    }
    
    @objc func onNoti(_ sender: UIButton) {
        delegate?.tapNoti?()
    }
}

