//
//  HomeCtr.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/19.
//

import UIKit

protocol HomeVcDelegate {
    func tappedCashup()
    func tappedRegistration()
    func homeUpdated()
}

class HomeVc: UIViewController {

    // profit
    @IBOutlet weak var sales: UIView!
    @IBOutlet weak var salesDesc: UILabel!
    @IBOutlet weak var totalSales: UILabel!
    @IBOutlet weak var seeDetails: UIButton!
    @IBOutlet weak var updateSales: UIButton!
    
    // not registered
    @IBOutlet weak var notReg: UIView!
    @IBOutlet weak var notRegTitle: UILabel!
    @IBOutlet weak var registration: UIButton!
    @IBOutlet weak var updateReg: UIButton!
    
    // guide
    @IBOutlet weak var guide: UIView!
    @IBOutlet weak var guideTitle: UILabel!
    @IBOutlet weak var guideDesc: UILabel!
    
    // banner
    @IBOutlet weak var bannerCollection: UICollectionView!
    
    var isHidden: Bool {
        get { return self.view.isHidden }
        set { self.view.isHidden = newValue }
    }
    
    var delegate: HomeVcDelegate?
    var vm: HomeVm!
    
    var bannerWidth: CGFloat = 180
    var bannerCellSpace: CGFloat = 16
    lazy var bannerMover = BannerMover(scrollview: bannerCollection, itemCount: CGFloat(vm.banners.count), itemWidth: bannerWidth, itemSpace: bannerCellSpace, horizontal: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        vm = HomeVm()
        initProfit()
        initNotReg()
        initGuide()
        initBanner()
        refreshSales()
        setBanners()
    }
    
    func initProfit() {
        sales.clipsToBounds = true
        sales.layer.cornerRadius = 12
        sales.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
        sales.layer.masksToBounds = false
        sales.layer.shadowOffset = CGSize(width: 0, height: 0)
        sales.layer.shadowRadius = 5
        sales.layer.shadowOpacity = 0.3
        
        let symbolColor = UIColor(red: 242.0 / 255.0, green: 123.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
        let profitString = NSMutableAttributedString(string: String.init(format: _strings[.thisMonthSalesTitle], "0\(_utils.getCurrencyString())"), attributes: [
          .font: UIFont(name: "NanumSquareB", size: 30)!,
          .foregroundColor: UIColor(white: 51.0 / 255.0, alpha: 1.0)
        ])
        profitString.addAttributes([
          .font: UIFont(name: "NanumSquareEB", size: 50)!,
          .foregroundColor: symbolColor
        ], range: NSRange(location: 8, length: 1))
        
        salesDesc.attributedText = profitString
        
        totalSales.font = UIFont(name: "NanumSquareR", size: 18)
        
        seeDetails.setTitle(_strings[.seeDetail], for: .normal)
        seeDetails.layer.borderWidth = 1
        seeDetails.layer.borderColor = symbolColor.cgColor
        seeDetails.layer.cornerRadius = seeDetails.frame.height / 2
    }
    
    func initNotReg() {
        notReg.clipsToBounds = true
        notReg.layer.cornerRadius = 12
        notReg.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
        
        notRegTitle.font = UIFont(name: "NanumSquareB", size: 17)
        notRegTitle.text = _strings[.needRegistrationTitle]
        
        registration.setTitle(_strings[.registerInfo], for: .normal)
        registration.layer.cornerRadius = registration.frame.height / 2
        registration.titleLabel?.font = UIFont(name: "NanumSquareB", size: 17)
    }

    func initGuide() {
        guide.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onGuide(_:))))
        
        guideTitle.font = UIFont(name: "NanumSquareB", size: 20)
        guideTitle.text = _strings[.guide]
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.lineSpacing = 10
        guideDesc.attributedText = NSMutableAttributedString(
            string: _strings[.guideDesc],
            attributes: [NSAttributedString.Key.paragraphStyle: titleParagraphStyle]
        )
        guideDesc.font = UIFont(name: "NanumSquareB", size: 15)
    }
    
    func initBanner() {
        let cellId = String(describing: BannerItem.self)
        let xib = UINib(nibName: cellId, bundle: nil)
        bannerCollection.register(xib, forCellWithReuseIdentifier: cellId)
        
//        let cellId = String(describing: BannerItem.self)
//        bannerCollection.register(BannerItem.self, forCellWithReuseIdentifier: cellId)
        
        bannerCollection.delegate = self
        bannerCollection.dataSource = self
        bannerCollection.clipsToBounds = false
        bannerCollection.isPagingEnabled = true
    }
    
    func setSales() {
        let symbolColor = UIColor(red: 242.0 / 255.0, green: 123.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
        let profitString = NSMutableAttributedString(string: String.init(format: _strings[.thisMonthSalesTitle], "\(vm.monthSales)\(_utils.getCurrencyString())"), attributes: [
          .font: UIFont(name: "NanumSquareB", size: 28)!,
          .foregroundColor: UIColor(white: 51.0 / 255.0, alpha: 1.0)
        ])
        profitString.addAttributes([
          .font: UIFont(name: "NanumSquareEB", size: 46)!,
          .foregroundColor: symbolColor
        ], range: NSRange(location: 8, length: vm.monthSales.count))
        
        salesDesc.attributedText = profitString
        
//        totalProfits.text = "가입 후 총 누적 수익금 \(vm.totalSales)원"
        totalSales.text = _strings[.salesDetailBtnTitle]
    }
    
    func updateSalesInfo() {
        let available = (_user.approval == .approved && _user.stored)
        notReg.isHidden = available
        
        setSales()
        
        DispatchQueue.main.async {
            if available { self.sales.unblur() }
            else { self.sales.blur(blurRadius: 3.0, cornerRadius: 12) }
        }
    }
    
    func refreshSales() {
        _cas.general.getMainTapInfo() { (_, _) in
            self.vm.monthSales = _user.monthlySales
            self.updateSalesInfo()
            self.delegate?.homeUpdated()
        }
    }
    
    func setBanners() {
        vm.getBanners() { (_, _) in
            self.bannerCollection.reloadData()
            self.bannerMover.delegate = self
            self.bannerMover.circulate()
        }
    }
    
    func rotateUpdateBtn(btn: UIButton) {
        let duration: CGFloat = 0.5
        UIView.animate(withDuration: duration, animations: { () -> Void in
            btn.transform = CGAffineTransform(rotationAngle: .pi)
        })
        
        UIView.animate(withDuration: duration / 2, animations: { () -> Void in
            btn.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { (_) in
            UIView.animate(withDuration: duration / 2, animations: { () -> Void in
                btn.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
//            btn.transform = CGAffineTransform(rotationAngle: 0)
        })
    }
}

// MARK: - Actions
extension HomeVc {
    @IBAction func onUpdateNotReg(_ sender: UIButton) {
        rotateUpdateBtn(btn: sender)
        refreshSales()
    }
    
    @IBAction func onUpdateSales(_ sender: UIButton) {
        rotateUpdateBtn(btn: sender)
        refreshSales()
    }
    
    @IBAction func onRegistration(_ sender: UIButton) {
        delegate?.tappedRegistration()
    }
    
    @IBAction func onShowCashup(_ sender: UIButton) {
        delegate?.tappedCashup()
    }
    
    @objc func onGuide(_ sender: UIGestureRecognizer) {
        let vc = AppGuideVc()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false)
    }
}

// MARK: - UICollectionView
extension HomeVc: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100000
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RegisterPictureCell.self), for: indexPath) as! RegisterPictureCell
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BannerItem.self), for: indexPath) as! BannerItem
        
        if vm.banners.count > 0 {
            let index = indexPath.row % vm.banners.count
            let bannerData = vm.banners[index]
            if let bannerImgData = bannerData.imgData {
                cell.configure(data: bannerImgData, pageUrl: bannerData.pageUrl)
                cell.backgroundColor = .clear
            } else {
                cell.configure(imgUrl: bannerData.imgUrl, pageUrl: bannerData.pageUrl) { (imgData) in
                    self.vm.banners[index].imgData = imgData
                }
            }
        } else {
            cell.configure(imgUrl: "", pageUrl: "")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: bannerWidth, height: bannerCollection.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return bannerCellSpace
    }
    
}

// MARK: - BannerMoverDelegate
extension HomeVc: BannerMoverDelegate {
    func moved() {
//        bannerCollection.moveItem(at: IndexPath(row: 0, section: 0), to: IndexPath(row: vm.banners.count - 1, section: 0))
        bannerCollection.scrollToNextItem()
    }
}

extension HomeVc: UIScrollViewDelegate {
    /*
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x < 0 {
            bannerMover.prev()
        } else if velocity.x > 0 {
            bannerMover.next()
        }
         
    }
     */
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        // 페이징
        if let cv = scrollView as? UICollectionView {
            
            let layout = cv.collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = layout.itemSize.width + layout.minimumLineSpacing
//            let cellWidth = bannerMover.itemWidth + bannerMover.itemSpace
            
            var offset = targetContentOffset.pointee
            let idx = (offset.x + cv.contentInset.left) / cellWidth
            
            var roundedIdx = round(idx)
            if scrollView.contentOffset.x > targetContentOffset.pointee.x {
                roundedIdx = floor(idx)
            } else if scrollView.contentOffset.x < targetContentOffset.pointee.x {
                roundedIdx = ceil(idx)
            } else {
                roundedIdx = round(idx)
            }
            
            if bannerMover.focusIndex > roundedIdx {
                bannerMover.focusIndex -= 1
                roundedIdx = bannerMover.focusIndex
            } else if bannerMover.focusIndex < roundedIdx {
                bannerMover.focusIndex += 1
                roundedIdx = bannerMover.focusIndex
            }
            
            offset = CGPoint(x: roundedIdx * cellWidth - cv.contentInset.left, y: 0)
            targetContentOffset.pointee = offset
            
        }
    }
    
}

// MARK: - HomeVmDelegate
/*
extension HomeVc: HomeVmDelegate {
    func ready() {
        refresh()
    }
}
*/
