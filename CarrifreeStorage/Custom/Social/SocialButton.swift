//
//  SocialButton.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/01/21.
//

import UIKit
import AuthenticationServices

protocol SocialButtonDelegate {
    func onTouch(sender: SocialButton)
}

class SocialButton: UIView {
    
    enum Social {
        case id
        case apple
        case kakao
        case naver
        case facebook
        case none
    }

    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!

    var xibLoaded: Bool = false
    var type: Social = .none
    var delegate: SocialButtonDelegate? = nil
    
    var bgColor: UIColor {
        switch type {
        case .id: return .systemGray
        case .apple: return .black
        case .kakao: return UIColor(red: 250/255, green: 223/255, blue: 75/255, alpha: 1)
        case .naver: return UIColor(red: 30/255, green: 200/255, blue: 0, alpha: 1)
        case .facebook: return UIColor(red: 66/255, green: 89/255, blue: 148/255, alpha: 1)
        default: return .white
        }
    }
    
    var imgName: String {
        switch type {
        case .id: return "square.and.pencil"
        case .apple: return "applelogo"
        case .kakao: return "icon-logo-kakao"
        case .naver: return "icon-logo-naver"
        case .facebook: return "icon-logo-facebook"
        default: return ""
        }
    }
    
    var titleText: String {
        switch type {
        case .id: return "\(_strings[.id])/\(_strings[.pw])\(_strings[.registerWith01])"
        case .apple: return "Apple\(_strings[.registerWith01])"
        case .kakao: return "\(_strings[.platformKakao])\(_strings[.registerWith01])"
        case .naver: return "\(_strings[.platformNaver])\(_strings[.registerWith01])"
        case .facebook: return "\(_strings[.platformFacebook])\(_strings[.registerWith02])"
        default: return ""
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    init(frame: CGRect, type: Social) {
        super.init(frame: frame)
        loadXib()
        configure(type: type)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: SocialButton.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        setImage()
        setGesture()
    }
    
    func configure(type: Social) {
        loadXib()
        self.type = type
        self.configure()
    }
    
    func setImage() {
        if type == .apple {
//            createAppleButton()
            img.image = UIImage(systemName: imgName)
            img.tintColor = .white
        } else if type == .id {
            img.image = UIImage(systemName: imgName)
            img.tintColor = .white
        } else {
            img.image = UIImage(named: imgName)
        }
        
        title.text = titleText
        bg.backgroundColor = bgColor
        bg.layer.cornerRadius = 6
        
        _log.log("social button image name: \(imgName)")
    }

    func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTouch(_:)))
        bg.addGestureRecognizer(tapGesture)
    }
    
    func createAppleButton() {
        let appleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signUp, authorizationButtonStyle: .black)
        appleButton.translatesAutoresizingMaskIntoConstraints = false

        bg.addSubview(appleButton)
        NSLayoutConstraint.activate([
            appleButton.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 0),
            appleButton.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: 0),
            appleButton.topAnchor.constraint(equalTo: bg.topAnchor, constant: 0),
            appleButton.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: 0)
        ])
    }
}

// MARK:- Actions
extension SocialButton {
    @objc func onTouch(_ sener: UIGestureRecognizer) {
        _log.log("onTouch - \(self.type)")
        delegate?.onTouch(sender: self)
    }
}
