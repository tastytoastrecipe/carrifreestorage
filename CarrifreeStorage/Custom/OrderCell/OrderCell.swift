//
//  OrderCell.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/09.
//

import UIKit

@objc protocol OrderCellDelegate {
    @objc optional func onTapCell(orderSeq: String, orderCategory: String)
}

class OrderCell: UIView {
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var band: UIView!
    @IBOutlet weak var img: UIImageView!            // 의뢰 물품 사진
    @IBOutlet weak var orderCase: UILabel!          // 의뢰 종류 (보관/위수탁)
    @IBOutlet weak var orderNo: UILabel!            // 의뢰 번호
    @IBOutlet weak var orderName: UILabel!          // 고객 이름
    @IBOutlet weak var orderLuggage: UILabel!       // 의뢰 물품 개수
    @IBOutlet weak var orderDuration: UILabel!      // 보관 시간
    @IBOutlet weak var orderTime: UILabel!          // 의뢰 요청 일시
    
    var delegate: OrderCellDelegate?
    var orderSeq: String = ""
    var orderCategory: String = ""

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var xibLoaded: Bool = false

    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: OrderCell.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:))))
        
        orderCase.font = UIFont(name: "NanumSquareB", size: 14)
        orderNo.font = UIFont(name: "NanumSquareR", size: 12)
        orderName.font = UIFont(name: "NanumSquareB", size: 14)
        orderLuggage.font = UIFont(name: "NanumSquareB", size: 17)
        orderDuration.font = UIFont(name: "NanumSquareB", size: 17)
        orderTime.font = UIFont(name: "NanumSquareB", size: 13)
        
        board.layer.shadowOffset = CGSize(width: 0, height: 1)
        board.layer.shadowRadius = 3
        board.layer.shadowOpacity = 0.3
        board.layer.cornerRadius = 10
        
        band.roundCorners(cornerRadius: 10, maskedCorners: [.layerMinXMinYCorner, .layerMinXMaxYCorner])
        
        img.image = UIImage(named: "img-default-store")
        img.contentMode = .scaleAspectFill
    }
    
    
    func configure(orderSeq: String, category: String, imgUrl: String, orderNo: String, orderName: String, orderLuggage: Int, orderDuration: String, orderTime: String) {
        configure()
        
        img.loadImage(url: imgUrl)
        self.orderSeq = orderSeq
        self.orderCategory = category
        self.orderCase.text = category
        self.orderNo.text = orderNo
        self.orderName.text = orderName
        self.orderTime.text = "요청일: \(orderTime)"
        self.orderLuggage.text = "\(orderLuggage)개"
        self.orderDuration.text = "\(orderDuration)시간"
    }
}

// MARK: - Actions
extension OrderCell {
    @objc func onTap(_ sender: UIGestureRecognizer) {
        delegate?.onTapCell?(orderSeq: self.orderSeq, orderCategory: self.orderCategory)
    }
}
