//
//  SocialSimpleButton.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/01/21.
//

import UIKit

protocol SocialSimpleButtonDelegate {
    func onTouch(sender: SocialSimpleButton)
}

class SocialSimpleButton: UIView {
    
    enum Social {
        case apple
        case kakao
        case naver
        case facebook
        case none
    }
    
    enum Corner {
        case rect
        case roundedRect
        case circle
    }
    
    enum ConstraintId: String, CaseIterable {
        case top = "top"
        case bottom = "bottom"
        case left = "left"
        case right = "right"
    }
    
    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet var layoutConsraints: [NSLayoutConstraint]!
    
    var xibLoaded: Bool = false
    var type: Social = .none
    var corner: Corner = .circle
    var delegate: SocialSimpleButtonDelegate? = nil
    
    
    var bgColor: UIColor {
        switch type {
        case .apple: return .black
        case .kakao: return UIColor(red: 250/255, green: 223/255, blue: 75/255, alpha: 1)
        case .naver: return UIColor(red: 30/255, green: 200/255, blue: 0, alpha: 1)
        case .facebook: return UIColor(red: 66/255, green: 89/255, blue: 148/255, alpha: 1)
        default: return .white
        }
    }
    
    var imgName: String {
        switch type {
        case .apple: return "icon-logo-apple"
        case .kakao: return "icon-logo-kakao"
        case .naver: return "icon-logo-naver"
        case .facebook: return "icon-logo-facebook"
        default: return ""
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    init(frame: CGRect, type: Social, corner: Corner = .circle) {
        super.init(frame: frame)
        loadXib()
        configure(type: type, corner: corner)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: SocialSimpleButton.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        setImage()
        setCorner()
        setGesture()
    }
    
    func configure(type: Social, corner: Corner = .circle) {
        loadXib()
        self.type = type
        self.corner = corner
        self.configure()
    }
    
    func setImage() {
        if type == .apple {
//            img.image = UIImage(systemName: imgName)
            
            // 애플 로그인 버튼일때는 [top, bottom, left, right] contraint를 0으로 설정한다 (정해진 이미지를 사용해야하기 때문에)
            for id in ConstraintId.allCases {
                if let contsraint = layoutConsraints.filter({ ($0.identifier ?? "") == id.rawValue }).first {
                    contsraint.constant = 0
                }
            }
        }
        
        img.image = UIImage(named: imgName)
        bg.backgroundColor = bgColor
        
        _log.log("social button image name: \(imgName)")
    }
    
    func setCorner() {
        DispatchQueue.main.async {
            
            switch self.corner {
            case .circle: self.bg.layer.cornerRadius = self.bg.frame.width / 2
            case .roundedRect: self.bg.layer.cornerRadius = 10
            case .rect: self.bg.layer.cornerRadius = 0
            }
        }
        
    }

    func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTouch(_:)))
        bg.addGestureRecognizer(tapGesture)
    }
}

// MARK:- Actions
extension SocialSimpleButton {
    @objc func onTouch(_ sener: UIGestureRecognizer) {
        delegate?.onTouch(sender: self)
    }
}
