//
//  SalesDetailVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/11/22.
//

import UIKit

class SalesDetailVc: UIViewController {

    @IBOutlet weak var board: UIView!
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
    
    // 완료된 주문의 하단 UI
    @IBOutlet weak var costTitle: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var extraCostTitle: UILabel!
    @IBOutlet weak var extraCost: UILabel!
    @IBOutlet weak var extraCostDesc: UILabel!
    @IBOutlet weak var totalCostTitle: UILabel!
    @IBOutlet weak var totalCost: UILabel!
    
    var vm: OrderDetailVm!
    var orderSeq: String = ""
    var orderCategory: String = ""
    var boardOriginY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        vm = OrderDetailVm(delegate: self, orderSeq: orderSeq)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        boardOriginY = board.frame.origin.y
        animateBoard(appear: true)
    }
    
    func configure() {
        board.clipsToBounds = true
        board.layer.cornerRadius = 18
        board.layer.shadowOffset = CGSize(width: 4, height: 0)
        board.layer.shadowRadius = 3
        board.layer.shadowOpacity = 0.1
        
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
    }
    
    func refresh() {
        orderNo.text = vm.data.orderNo
        orderDate.text = vm.data.orderDate
        orderName.text = vm.data.name
        contact.text = vm.data.phone
        luggages.text = vm.data.getLuggageSymbolString()
        
        // let remain = during.truncatingRemainder(dividingBy: oneHourSecond)
        
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
        
        let costStr = _utils.getDelimiter(str: vm.data.cost)
        cost.text = "\(costStr)(\(_strings[.vat]))"
        
        let extraCostStr = _utils.getDelimiter(str: vm.data.extraCost)
        extraCost.text = "\(extraCostStr)(\(_strings[.vat]))"
        
        let totalCostStr = _utils.getDelimiter(str: vm.data.totalCost)
        totalCost.text = "\(totalCostStr)(\(_strings[.vat]))"
        
        orderStamp.image = UIImage(named: "img-order-complete")
        orderStamp.isHidden = false
        
        // 보관 물품 이미지 표시
        /*
        pictureStack.removeAllArrangedSubviews()
        for imgUrl in vm.data.imgs {
            
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
            
        }
         */
    }
    
    func setPictures(imgUrls: [String]) {
        // 보관 물품 이미지 표시
        pictureStack.removeAllArrangedSubviews()
        for imgUrl in imgUrls {
            
            let picture = UIImageView()
            picture.contentMode = .scaleAspectFill
            picture.loadImage(url: imgUrl)
            picture.contentMode = .scaleAspectFill
            picture.translatesAutoresizingMaskIntoConstraints = false
            picture.clipsToBounds = true
            pictureStack.addArrangedSubview(picture)
            NSLayoutConstraint.activate([
                picture.widthAnchor.constraint(equalToConstant: 100)
            ])
        }
    }
    
    func animateBoard(appear: Bool, completion: (() -> Void)? = nil) {
        if appear {
            board.frame.origin.y = self.view.frame.height
            UIView.animate(withDuration: 0.3, animations: {
                self.board.frame.origin.y = self.boardOriginY
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
    
    func exit() {
        self.view.backgroundColor = .clear
        animateBoard(appear: false) {
            self.dismiss(animated: false)
        }
    }
    
}

// MARK: - Actions
extension SalesDetailVc {
    @objc func onExit(_ sender: UIButton) {
        exit()
    }
    
    @objc func onSwipe(_ sender: UIGestureRecognizer) {
        exit()
    }
    
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
    
    @IBAction func onCommentBalloon(_ sender: UIButton) {
        guard let commentText = comment.text else { return }
        let alert = _utils.createSimpleAlert(title: _strings[.requests], message: commentText, buttonTitle: _strings[.ok])
        self.present(alert, animated: true)
    }
}

// MARK: - OrderDetailVmDelegate
extension SalesDetailVc: OrderDetailVmDelegate {
    func ready() {
        refresh()
        
        vm.getOrderPictures() { (success, msg) in
            self.setPictures(imgUrls: self.vm.data.imgs)
        }
    }
}
