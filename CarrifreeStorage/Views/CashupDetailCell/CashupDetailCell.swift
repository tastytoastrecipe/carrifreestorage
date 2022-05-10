//
//  CashupDetailCell.swift
//  CarrifreeStorage
//
//  Created by orca on 2021/11/20.
//

import UIKit

class CashupDetailCell: UIView {
    
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var orderNo: UILabel!
    @IBOutlet weak var luggageCountTitle: UILabel!
    @IBOutlet weak var luggageCount: UILabel!
    @IBOutlet weak var durationTitle: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var sales: UILabel!
    @IBOutlet weak var dotLine: UIView!
    
    var xibLoaded: Bool = false

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func loadXib() {
        if xibLoaded { return }
        guard let view = self.loadNib(name: String(describing: CashupDetailCell.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        
        board.layer.cornerRadius = 10
        board.layer.shadowOffset = CGSize(width: 1, height: 1)
        board.layer.shadowRadius = 3
        board.layer.shadowOpacity = 0.3
        
        _utils.setText(bold: .bold, size: 14, text: "", label: date)
            
        let categoryColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        category.layer.cornerRadius = category.frame.height / 2
        category.layer.borderWidth = 1
        category.layer.borderColor = categoryColor.cgColor
        _utils.setText(bold: .regular, size: 13, text: "", color: categoryColor, label: category)
//        category.textColor = categoryColor
        
        _utils.setText(bold: .bold, size: 15, text: "", label: orderNo)
        
        _utils.setText(bold: .regular, size: 14, text: "보관건수:", label: luggageCountTitle)
        _utils.setText(bold: .bold, size: 14, text: "", label: luggageCount)
        
        _utils.setText(bold: .regular, size: 14, text: "보관시간:", label: durationTitle)
        _utils.setText(bold: .bold, size: 14, text: "", label: duration)
        
        _utils.setText(bold: .bold, size: 15, text: "", label: sales)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            _utils.drawDottedLine(start: CGPoint.zero, end: CGPoint(x: self.dotLine.frame.width, y: 0), view: self.dotLine)
        }
        
    }
    
    func configure(category: String, day: String, orderNo: String, luggageCount: Int, duration: Int, sales: Int) {
        configure()
        
        self.category.text = "  \(category)  "
        self.date.text = "\(day)일"
        self.orderNo.text = orderNo
        self.luggageCount.text = "\(luggageCount)건"
        self.duration.text = "\(duration)시간"
        
        let currencySymbol = _utils.getCurrencyString()
        self.sales.text = "\(sales)\(currencySymbol)"
    }
}
