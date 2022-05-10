//
//  OrderProcess.swift
//  TestProject
//
//  Created by orca on 2021/11/14.
//

import UIKit

class OrderProcess: UIView {

    @IBOutlet weak var processImg01: UIImageView!
    @IBOutlet weak var processTitle01: UILabel!
    
    @IBOutlet weak var processBoard02: UIView!
    @IBOutlet weak var processImg02: UIImageView!
    @IBOutlet weak var processTitle02: UILabel!
    
    @IBOutlet weak var processImg03: UIImageView!
    @IBOutlet weak var processTitle03: UILabel!
    
    @IBOutlet weak var line01: UIView!
    @IBOutlet weak var line02: UIView!
    @IBOutlet weak var line03: UIView!
    
    var orderStatus: String = ""
    var xibLoaded: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: OrderProcess.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        let processFont = UIFont(name: "NanumSquareR", size: 13)
        processTitle01.font = processFont
        processTitle02.font = processFont
        processTitle03.font = processFont
    }
    
    func configure(orderStatus: String, processTitle01: String, processTitle02: String, processTitle03: String) {
        configure()
        self.processTitle01.text = processTitle01
        self.processTitle02.text = processTitle02
        self.processTitle03.text = processTitle03
        if let status = OrderStatus(rawValue: orderStatus) { setStatus(status: status) }
    }
    
    func setStatus(status: OrderStatus) {
        let normalColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        let completeColor = UIColor(red: 152/255, green: 196/255, blue: 85/255, alpha: 1)
        let normalFont = UIFont(name: "NanumSquareR", size: 13)
        let completeFont = UIFont(name: "NanumSquareEB", size: 13)
        let completeImg = "flag.circle.fill"
        switch status {
        
        // 주문대기
        case .purchased:
            processImg01.image = UIImage.init(systemName: completeImg)
            processImg01.tintColor = completeColor
            processImg02.image = UIImage.init(systemName: "2.circle")
            processImg02.tintColor = normalColor
            processImg03.image = UIImage.init(systemName: "3.circle")
            processImg03.tintColor = normalColor
            
            processTitle01.textColor = completeColor
            processTitle02.textColor = normalColor
            processTitle03.textColor = normalColor
            
            processTitle01.font = completeFont
            processTitle02.font = normalFont
            processTitle03.font = normalFont
            
            line01.backgroundColor = normalColor
            line02.backgroundColor = normalColor
            line03.backgroundColor = normalColor
            line03.isHidden = true
            
        // 보관중
        case .entrust:
            processImg01.image = UIImage.init(systemName: completeImg)
            processImg01.tintColor = completeColor
            processImg02.image = UIImage.init(systemName: completeImg)
            processImg02.tintColor = completeColor
            processImg03.image = UIImage.init(systemName: "3.circle")
            processImg03.tintColor = normalColor
            
            processTitle01.textColor = completeColor
            processTitle02.textColor = completeColor
            processTitle03.textColor = normalColor
            
            processTitle01.font = completeFont
            processTitle02.font = completeFont
            processTitle03.font = normalFont
            
            line01.backgroundColor = completeColor
            line02.backgroundColor = normalColor
            line03.backgroundColor = normalColor
            line03.isHidden = true
            
        // 처리완료
        case .take:
            processImg01.image = UIImage.init(systemName: completeImg)
            processImg01.tintColor = completeColor
            processImg02.image = UIImage.init(systemName: completeImg)
            processImg02.tintColor = completeColor
            processImg03.image = UIImage.init(systemName: completeImg)
            processImg03.tintColor = completeColor
            
            processTitle01.textColor = completeColor
            processTitle02.textColor = completeColor
            processTitle03.textColor = completeColor
            
            processTitle01.font = completeFont
            processTitle02.font = completeFont
            processTitle03.font = completeFont
            
            line01.backgroundColor = completeColor
            line02.backgroundColor = completeColor
            line03.backgroundColor = completeColor
            line03.isHidden = true
            
        // 취소
        case .canceled:
            processBoard02.isHidden = true
            processImg01.image = UIImage.init(systemName: completeImg)
            processImg01.tintColor = completeColor
            processImg03.image = UIImage.init(systemName: "minus.circle.fill")
            processImg03.tintColor = completeColor
            processTitle03.text = "취소완료"
            
            processTitle01.textColor = completeColor
            processTitle02.textColor = completeColor
            processTitle03.textColor = completeColor
            
            processTitle01.font = completeFont
            processTitle02.font = completeFont
            processTitle03.font = completeFont
            
            line01.backgroundColor = completeColor
            line02.backgroundColor = completeColor
            line03.backgroundColor = completeColor
            line03.isHidden = false
            
        default: break
        }
        
        
    }
}
