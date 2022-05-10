//
//  CashupDetailVc.swift
//  CarrifreeStorage
//
//  Created by orca on 2021/11/20.
//

import UIKit

class CashupDetailVc: UIViewController {

    @IBOutlet weak var board: UIView!
    @IBOutlet weak var vcHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var vcTitle: UILabel!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var salesTitle: UILabel!
    @IBOutlet weak var sales: UILabel!
    
    let maxHeight: CGFloat = 600            // 뷰의 최대 높이
    let defaultHeight: CGFloat = 130        // 매출이 없을때 전체 뷰의 높이
    let cellHeight: CGFloat = 120           // cell(매출)의 높이
    let cellSpace: CGFloat = 6              // cell(매출)의 간격
    
    var salesTotal: Int = 0
    var salesDate: Date!
    var datas: [DailySales] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        refresh()
//        vm = CashupDetailVm(delegate: self)
    }
    
    func configure() {
        board.isHidden = true
        board.layer.cornerRadius = 18
        board.clipsToBounds = true
        
        vcTitle.text = _strings[.cashupInfo]
        vcTitle.font = UIFont(name: "NanumSquareEB", size: 20)
        
        dateTitle.text = "\(_strings[.salesDuration]): "
        dateTitle.font = UIFont(name: "NanumSquareR", size: 14)
        let dateStr = salesDate.toOnlyDateString()
        _utils.setText(bold: .regular, size: 14, text: dateStr, color: .label, label: date)
        
        salesTitle.text = "\(_strings[.cost7]): "
        salesTitle.font = UIFont(name: "NanumSquareR", size: 14)
        let salesStr = "\(salesTotal.delimiter)\(_utils.getCurrencyString())"
        _utils.setText(bold: .regular, size: 14, text: salesStr, color: .label, label: sales)
        
        // down gesture
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe(_:)))
        swipe.numberOfTouchesRequired = 1
        swipe.direction = .down
        self.view.addGestureRecognizer(swipe)
        
        // exit button
        let exitBtn = UIButton()
        exitBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        exitBtn.tintColor = .systemGray
        exitBtn.addTarget(self, action: #selector(self.onExit(_:)), for: .touchUpInside)
        exitBtn.isHidden = true
        board.addSubview(exitBtn)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            exitBtn.isHidden = false
            exitBtn.frame = CGRect(x: self.board.frame.width - 50, y: 0, width: 50, height: 50)
        }
        
        stack.spacing = cellSpace
    }
    
    override func viewDidAppear(_ animated: Bool) {
        board.isHidden = false
        animateBoard(appear: true)
    }

    func animateBoard(appear: Bool, completion: (() -> Void)? = nil) {
        if appear {
            vcHeightConstraint.constant = getViewHeight(cellCount: self.datas.count)
            board.frame.origin.y = self.view.frame.height
            UIView.animate(withDuration: 0.3, animations: {
                let boardY = self.view.frame.height - self.vcHeightConstraint.constant
                self.board.frame.origin.y = boardY
            }, completion: { (_) in
                completion?()
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.board.frame.origin.y = self.view.frame.height
            }, completion: { (_) in
                completion?()
            })
        }
        
    }
    
    func getViewHeight(cellCount: Int) -> CGFloat {
        var height: CGFloat = defaultHeight
        height += (CGFloat(cellCount) * cellHeight + cellSpace)
        if height > maxHeight { height = maxHeight }
        return height
    }
    
    func refresh() {
        stack.removeAllArrangedSubviews()
        for data in datas {
            let cell = CashupDetailCell()
            cell.configure(category: data.category, day: data.day, orderNo: data.orderNo, luggageCount: data.luggageCount, duration: data.durationHour, sales: data.sales)
            stack.addArrangedSubview(cell)
            
            cell.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cell.heightAnchor.constraint(equalToConstant: cellHeight)
            ])
        }
    }
    
    func exit() {
        self.view.backgroundColor = .clear
        animateBoard(appear: false) {
            self.dismiss(animated: false)
        }
    }
}

// MARK: - Actions
extension CashupDetailVc {
    @objc func onExit(_ sender: UIButton) {
        exit()
    }
    
    @objc func onSwipe(_ sender: UIGestureRecognizer) {
        exit()
    }
}
