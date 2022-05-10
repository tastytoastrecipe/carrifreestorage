//
//  OrderDetailVc.swift
//  TestProject
//
//  Created by orca on 2021/11/14.
//

import UIKit

@objc protocol OrderDetailVcDelegate {
    @objc func deletedOrderDetailVc()
}

class OrderDetailVc: UIViewController {
    
    @IBOutlet weak var orderProcess: OrderProcess!      // 주문 진행 과정 UI
    @IBOutlet weak var detailBoard: UIView!
    @IBOutlet weak var pictureStack: UIStackView!
    
    @IBOutlet weak var band01: UIView!
    @IBOutlet weak var band02: UIView!

    @IBOutlet weak var orderNoTitle: UILabel!
    @IBOutlet weak var orderNo: UILabel!
    @IBOutlet weak var orderDateTitle: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var orderStamp: UIImageView!
    @IBOutlet weak var orderNameTitle: UILabel!
    @IBOutlet weak var orderName: UILabel!
    @IBOutlet weak var contactTitle: UILabel!
    @IBOutlet weak var contact: UILabel!
    @IBOutlet weak var emailTitle: UILabel!
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var luggagesTitle: UILabel!
    @IBOutlet weak var luggages: UILabel!
    @IBOutlet weak var durationTitle: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var durationDetail: UILabel!
    @IBOutlet weak var commentTitle: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    // 완료되지않은 주문의 하단 UI
    @IBOutlet weak var beforeCompleteBoard: UIView!
    @IBOutlet weak var beforeCostTitle: UILabel!
    @IBOutlet weak var beforeCost: UILabel!
    
    // 완료할(보관중인) 주문의 하단 UI
    @IBOutlet weak var goCompleteBoard: UIView!
    @IBOutlet weak var goCostTitle: UILabel!
    @IBOutlet weak var goDesc: UILabel!
    @IBOutlet weak var goCost: UILabel!
    @IBOutlet weak var confirm: UIButton!
    
    // 완료된 주문의 하단 UI
    @IBOutlet weak var afterCompleteBoard: UIView!
    @IBOutlet weak var costTitle: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var extraCostTitle: UILabel!
    @IBOutlet weak var extraCost: UILabel!
    @IBOutlet weak var extraCostDesc: UILabel!
    @IBOutlet weak var totalCostTitle: UILabel!
    @IBOutlet weak var totalCost: UILabel!
    
    // 취소된 주문의 하단 UI
    @IBOutlet weak var cancelBoard: UIView!
    @IBOutlet weak var refundCostDesc: UILabel!
    @IBOutlet weak var refundCostTitle: UILabel!
    @IBOutlet weak var refundCost: UILabel!
    
    var delegate: OrderDetailVcDelegate?
    var vm: OrderDetailVm!
    var orderSeq: String = ""
    var orderCategory: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        vm = OrderDetailVm(delegate: self, orderSeq: orderSeq)
    }

    func configure() {
        
        detailBoard.layer.cornerRadius = 18
        detailBoard.layer.shadowOffset = CGSize(width: 4, height: 0)
        detailBoard.layer.shadowRadius = 3
        detailBoard.layer.shadowOpacity = 0.1
        
        band01.roundCorners(cornerRadius: 18, maskedCorners: [.layerMinXMaxYCorner, .layerMinXMinYCorner])
        band02.roundCorners(cornerRadius: 18, maskedCorners: [.layerMinXMinYCorner])
        
        let titleFont = UIFont(name: "NanumSquareR", size: 14)
        let valueFont = UIFont(name: "NanumSquareB", size: 15)
        
        orderNoTitle.text = _strings[.requestNo]
        orderNoTitle.font = UIFont(name: "NanumSquareB", size: 18)
        
        orderNo.text = ""
        orderNo.font = UIFont(name: "NanumSquareR", size: 15)
        
        orderDateTitle.text = _strings[.storage]
        orderDateTitle.font = titleFont
        orderDateTitle.textColor = UIColor(red: 242/255, green: 123/255, blue: 87/255, alpha: 1)
        orderDateTitle.layer.borderColor = orderDateTitle.textColor.cgColor
        orderDateTitle.layer.borderWidth = 1
        orderDateTitle.textAlignment = .center
        
        orderDate.text = ""
        orderDate.font = titleFont
        
        orderNameTitle.text = "\(_strings[.whoOrdered]):"
        orderNameTitle.font = titleFont
        
        orderName.text = ""
        orderName.font = valueFont
        
        contactTitle.text = "\(_strings[.contactNum]):"
        contactTitle.font = titleFont
        
        contact.text = ""
        contact.font = valueFont
        
        emailTitle.text = "\(_strings[.eMail]):"
        emailTitle.font = titleFont
        
        email.text = ""
        email.font = valueFont
        
        luggagesTitle.text = "\(_strings[.luggageInfo]):"
        luggagesTitle.font = titleFont
        
        luggages.text = ""
        luggages.font = valueFont
        
        durationTitle.text = "\(_strings[.during]):"
        durationTitle.font = titleFont
        
        duration.text = ""
        duration.font = valueFont
        
        durationDetail.text = ""
        durationDetail.font = titleFont
        
        commentTitle.text = "\(_strings[.requests]):"
        commentTitle.font = titleFont
        
        comment.text = ""
        comment.font = valueFont
        
        beforeCompleteBoard.isHidden = true
        
        _utils.setText(bold: .bold, size: 18, text: "", label: beforeCostTitle)
        _utils.setText(bold: .bold, size: 24, text: "", color: .systemRed, label: beforeCost)
        
        confirm.titleLabel?.font = valueFont
        confirm.addTarget(self, action: #selector(self.onConfirm(_:)), for: .touchUpInside)
                        
        afterCompleteBoard.isHidden = true
        
        costTitle.text = "\(_strings[.cost3]):"
        costTitle.font = titleFont
        
        cost.text = ""
        cost.font = valueFont
        
        extraCostTitle.text = "\(_strings[.cost4]):"
        extraCostTitle.font = titleFont
        
        extraCostDesc.text = "*\(_strings[.payDirect])"
        extraCostDesc.font = UIFont(name: "NanumSquareR", size: 13)
        
        extraCost.text = ""
        extraCost.font = valueFont
        
        totalCostTitle.text = "\(_strings[.cost5]):"
        totalCostTitle.font = titleFont
        
        totalCost.text = ""
        totalCost.font = valueFont
        
        cancelBoard.isHidden = true
        
        refundCostDesc.text = "\(_strings[.canceledOrder])"
        refundCostDesc.font = UIFont(name: "NanumSquareB", size: 20)
        
        refundCostTitle.text = "\(_strings[.cost6]):"
        refundCostTitle.font = titleFont
        
        refundCost.text = ""
        refundCost.font = valueFont
        
        _utils.setText(bold: .bold, size: 14, text: "\(_strings[.cost4]):", label: goCostTitle)
        _utils.setText(bold: .bold, size: 15, text: "", color: .systemRed, label: goCost)
        _utils.setText(bold: .regular, size: 13, text: "*(직접 정산)", color: .systemRed, label: goDesc)
    }
    
    func refresh() {
        orderNo.text = vm.data.orderNo
        orderDate.text = vm.data.orderDate
        orderName.text = vm.data.name
        contact.text = vm.data.phone
        luggages.text = vm.data.getLuggageSymbolString()
        
        var durationText = ""
        if vm.data.during < 60 {
            durationText = "\(vm.data.during)분"
        } else {
            durationText = "\(vm.data.during / 60)\(_strings[.hour])"
            let remain = Double(vm.data.during).truncatingRemainder(dividingBy: 60)
            let remainInt = Int(remain)
            durationText += " \(remainInt)분"
        }
        duration.text = durationText
        durationDetail.text = "\(vm.data.startTime) ~ \(vm.data.endTime)"
        comment.text = vm.data.comment
        email.text = vm.data.email
        
        if let orderCategory = OrderCategory(rawValue: vm.data.category) {
            orderDateTitle.text = orderCategory.name
        }
        
        let costDelimiter = _utils.getDelimiter(str: vm.data.cost)
        
        let currencyString = _utils.getCurrencyString()
        if let orderStatus = OrderStatus(rawValue: vm.data.orderStatus) {
            if orderStatus == .purchased{
                beforeCompleteBoard.isHidden = false
                afterCompleteBoard.isHidden = true
                cancelBoard.isHidden = true
                goCompleteBoard.isHidden = true
                
                beforeCostTitle.text = "\(_strings[.cost3]):"
                beforeCost.text = "\(costDelimiter)\(currencyString)(\(_strings[.vat]))"
                
                confirm.setTitle(_strings[.goOrder], for: .normal)
                
                orderStamp.isHidden = true
                
            } else if orderStatus == .entrust {
                goCompleteBoard.isHidden = false
                beforeCompleteBoard.isHidden = true
                afterCompleteBoard.isHidden = true
                cancelBoard.isHidden = true
                
                // 추가금액이 0보다 클경우에만 금액을 표시하고 그외에는 0으로 표시함
                var extraCostStr = "0"
                let extraCostInt = _utils.getIntFromDelimiter(str: vm.data.extraCost)
                if extraCostInt > 0 { extraCostStr = "\(extraCostInt)" }
                goCost.text = "\(extraCostStr)\(currencyString)(\(_strings[.vat]))"
                beforeCostTitle.text = "\(_strings[.cost4]):"
                beforeCost.text = "\(costDelimiter)\(currencyString)(\(_strings[.vat]))"
                
                confirm.setTitle(_strings[.orderDone], for: .normal)
                
                orderStamp.isHidden = true
                
            } else if orderStatus == .take {
                beforeCompleteBoard.isHidden = true
                afterCompleteBoard.isHidden = false
                cancelBoard.isHidden = true
                goCompleteBoard.isHidden = true
                
                cost.text = "\(costDelimiter)\(currencyString)(\(_strings[.vat]))"
                
                // 추가금액이 0보다 클경우와 아닐경우의 설명 문구를 구분해서 표시함
                let extraCostStr = _utils.removeDelimiter(str: vm.data.extraCost)
                let extraCostInt = Int(extraCostStr) ?? 0
                if extraCostInt < 0 {
                    extraCostDesc.text = "*\(_strings[.autoRefund])"
                } else {
                    extraCostDesc.text = "*\(_strings[.payDirect])"
                }
                
                extraCost.text = "\(extraCostInt.delimiter)\(currencyString)(\(_strings[.vat]))"
                
                let totalCostStr = _utils.getDelimiter(str: vm.data.totalCost)
                totalCost.text = "\(totalCostStr)\(currencyString)(\(_strings[.vat]))"
                
                orderStamp.image = UIImage(named: "img-order-complete")
                orderStamp.isHidden = false
                
            } else if orderStatus == .canceled {
                goCompleteBoard.isHidden = true
                beforeCompleteBoard.isHidden = true
                afterCompleteBoard.isHidden = true
                cancelBoard.isHidden = false
                
                refundCost.text = "\(costDelimiter)\(currencyString)(\(_strings[.refundDone]))"
                                                                                                    
                refundCostDesc.text = _strings[.canceledOrder]
                
                orderStamp.image = UIImage(named: "img-order-cancel")
                orderStamp.isHidden = false
            }
        }
        
        // 주문 진행 과정 표시
        orderProcess.configure(orderStatus: vm.data.orderStatus, processTitle01: _strings[.orderStatusPurchasedTitle], processTitle02: _strings[.orderStatusEntrustTitle], processTitle03: _strings[.orderStatusTakeTitle])
        
    }
    
    func setPictures(imgUrls: [String]) {
        // 보관 물품 이미지 표시
        pictureStack.removeAllArrangedSubviews()
        for imgUrl in imgUrls {
            
            let picture = UIImageView()
            picture.contentMode = .scaleAspectFill
//            picture.loadImage(url: URL(string: imgUrl))
            picture.loadImage(url: imgUrl)
            picture.contentMode = .scaleAspectFill
            picture.translatesAutoresizingMaskIntoConstraints = false
            picture.clipsToBounds = true
            pictureStack.addArrangedSubview(picture)
            NSLayoutConstraint.activate([
                picture.widthAnchor.constraint(equalToConstant: 100)
            ])
            
            
            
            /*
            let pictureView = RegStoragePictureCell()
            pictureView.configure(isMain: false)
            pictureView.setImageWithUrl(url: imgUrl, registered: false, seq: "", deleteBtnHidden: true)
            pictureView.deleteBtn.isHidden = true
            pictureView.isUserInteractionEnabled = false
            pictureStack.addArrangedSubview(pictureView)
            
            pictureView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pictureView.widthAnchor.constraint(equalToConstant: 100)
            ])
            */
        }
    }
    
    func exit() {
        self.view.removeFromSuperview()
        self.removeFromParent()
        delegate?.deletedOrderDetailVc()
    }
}

// MARK: - Actions
extension OrderDetailVc {
    @IBAction func onExit(_ sender: UIButton) { exit() }
    
    @IBAction func onCall(_ sender: UIButton) {
        guard let contactText = contact.text, contactText.count > 0 else { return }
        
        // URLScheme 문자열을 통해 URL 인스턴스를 만들어 줍니다.
        if let url = NSURL(string: "tel://\(contactText)"),
           
            //canOpenURL(_:) 메소드를 통해서 URL 체계를 처리하는 데 앱을 사용할 수 있는지 여부를 확인
           UIApplication.shared.canOpenURL(url as URL) {
            
            //사용가능한 URLScheme이라면 open(_:options:completionHandler:) 메소드를 호출해서
            //만들어둔 URL 인스턴스를 열어줍니다.
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @objc func onConfirm(_ sender: UIButton) {
        let noticeVc = OrderNoticeVc()
        noticeVc.status = vm.data.orderStatus
        noticeVc.modalPresentationStyle = .overFullScreen
        noticeVc.delegate = self
        self.present(noticeVc, animated: false)
    }
    
    @IBAction func onCommentBalloon(_ sender: UIButton) {
        guard let commentText = comment.text else { return }
        let alert = _utils.createSimpleAlert(title: _strings[.requests], message: commentText, buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
}

// MARK: - OrderDetailVmDelegate
extension OrderDetailVc: OrderDetailVmDelegate {
    func ready() {
        refresh()
        
        vm.getOrderPictures() { (success, msg) in
            self.setPictures(imgUrls: self.vm.data.imgs)
        }
    }
}

// MARK: - OrderNoticeVcDelegate
extension OrderDetailVc: OrderNoticeVcDelegate {
    func onContinue() {
        guard let currentStatus = OrderStatus(rawValue: vm.data.orderStatus) else { _log.logWithArrow("OrderDetailiVc::onConfirm", "orderStatus is nil..."); return }
        
        // 변경할 상태값(주문 진행 상황) 생성
        var orderStatusStr = ""
        if currentStatus == .purchased {
            orderStatusStr = OrderStatus.entrust.rawValue
        } else if currentStatus == .entrust {
            orderStatusStr = OrderStatus.take.rawValue
        }
        
        if orderStatusStr.isEmpty { return }
        
        // 주문 진행 요청
        vm.updateOrderStatus(orderStatus: orderStatusStr) { (success, msg) in
            if success {
                // OrderReportVc 설정
                var orderReportCase = OrderReportCase.orderStart
                if currentStatus == .entrust { orderReportCase = .orderDone }
                
                // OrderReportVc 표시
                let vc = OrderReportVc()
                vc.reportCase = orderReportCase
                vc.modalPresentationStyle = .overFullScreen
                _utils.topViewController()?.present(vc, animated: false)
                
                self.refresh()
                
            } else {
                let alert = _utils.createSimpleAlert(title: _strings[.requestFailed], message: msg, buttonTitle: _strings[.ok])
                self.present(alert, animated: true)
            }
        }
        
    }
}
