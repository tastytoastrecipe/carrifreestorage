//
//  CashupCell.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/18.
//

import UIKit

enum CashupCellCase {
    case sales              // 매출
    case cashup             // 정산
}

protocol CashupCellDelegate {
    func cashupCellTapped(index: Int)
}

class CashupCell: UIView {
    
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var orderIcon: UIImageView!
    @IBOutlet weak var title01: UILabel!
    @IBOutlet weak var desc01: UILabel!
    @IBOutlet weak var title02: UILabel!
    @IBOutlet weak var desc02: UILabel!
    @IBOutlet weak var sales: UILabel!
    
    var cellCase: CashupCellCase = .sales
    var delegate: CashupCellDelegate? = nil
    var xibLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: CashupCell.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        board.layer.cornerRadius = 10
        board.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:))))
        board.layer.shadowOffset = CGSize(width: 1, height: 1)
        board.layer.shadowRadius = 3
        board.layer.shadowOpacity = 0.3
        
        title01.font = UIFont(name: "NanumSquareB", size: 13)
        title01.textAlignment = .center
        
        desc01.font = UIFont(name: "NanumSquareR", size: 12)
        
        title02.font = UIFont(name: "NanumSquareR", size: 12)
        title02.textColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        title02.textAlignment = .center
        title02.layer.cornerRadius = title02.frame.height / 2
        title02.layer.borderColor = title02.textColor.cgColor
        title02.layer.borderWidth = 1
        
//        desc02.text = ""
        desc02.font = UIFont(name: "NanumSquareB", size: 13)
        
        sales.font = UIFont(name: "NanumSquareB", size: 14)
    }
    
    func configure(cellCase: CashupCellCase, orderCategory: String, day: String, orderNo: String, orderInfo: String, sales: Int) {
        configure()
        update(cellCase: cellCase, orderCategory: orderCategory, day: day, orderNo: orderNo, orderInfo: orderInfo, sales: sales)
    }
    
    func configure(cellCase: CashupCellCase, data: DailySales) {
        configure()
        let orderInfoText = "보관건수: \(data.luggageCount), 보관시간: \(data.durationHour / 60)시간"
        update(cellCase: cellCase, orderCategory: data.category, day: data.day, orderNo: data.orderNo, orderInfo: orderInfoText, sales: data.sales)
    }

    func update(cellCase: CashupCellCase, orderCategory: String, day: String, orderNo: String, orderInfo: String, sales: Int) {
        self.cellCase = cellCase
        
        switch cellCase {
        case .sales:
            orderIcon.image = UIImage(systemName: "circle.fill")
        case .cashup:
            orderIcon.image = UIImage(systemName: "circle")
            title02.text = "정산"
            self.desc01.text = "정산기준"
        }
        
//        if let category = OrderCategory(rawValue: orderCategory) {
//            title02.text = category.name
//            self.desc01.text = orderNo
//        }
        title02.text = orderCategory
        desc01.text = orderNo
        desc02.text = orderInfo
        title01.text = "\(day)일"
        
        let currencyString = _utils.getCurrencyString()
        let salesStr = "\(sales.delimiter)\(currencyString)"
        self.sales.text = salesStr
    }
}

// MARK: - Actions
extension CashupCell {
    @objc func onTap(_ sender: UIGestureRecognizer) {
        delegate?.cashupCellTapped(index: self.tag)
    }
}
