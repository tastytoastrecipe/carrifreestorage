//
//  ImageCollection.swift
//  Carrifree
//
//  Created by plattics-kwon on 2021/04/16.
//  Copyright © 2021 plattics. All rights reserved.
//

import UIKit

class SwipeImage: UIView {
    
    enum PageControllDirection {
        case top
        case left
        case bottomUp       // 이미지 하단의 바로 위
        case bottomDown     // 이미지 하단의 바로 아래
        case right
    }
    
    @IBOutlet weak var collection: UICollectionView!
    
    let cellId = "swipeimagecell"
    var pageControl: UIPageControl!
    var datas: [Data?] = []
    var urls: [String] = []
    var isUrl: Bool = false
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
        guard let view = self.loadNib(name: String(describing: SwipeImage.self)) else { return }
        xibLoaded = true
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func configure() {
        loadXib()
        setDefault()
    }
    
    func configure(imgUrls: [String]) {
        loadXib()
        urls = imgUrls
        isUrl = true
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            self.setDefault()
            self.setPageControl()
//        }
    }
    
    func configure(imgDatas: [Data?]) {
        loadXib()
        isUrl = false
        datas = imgDatas
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            self.setDefault()
            self.setPageControl()
//        }
    }
    
    func setDefault() {
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collection.delegate = self
        collection.dataSource = self
    }
    
    func setPageControl() {
        let pageControlHeight: CGFloat = 30
        pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 1, height: pageControlHeight))
        
        if isUrl {
            pageControl.numberOfPages = urls.count
        } else {
            pageControl.numberOfPages = datas.count
        }
        
        pageControl.backgroundColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.5)//.clear
        pageControl.layer.cornerRadius = 4
        pageControl.addTarget(self, action: #selector(onPageChanged(_:)), for: .valueChanged)
        pageControl.sizeToFit()
        self.addSubview(pageControl)
        setPageControllPosition(direction: .bottomUp)
    }
    
    func setPageControllColor(backgroundColor: UIColor, currentIndicatorColor: UIColor, indicatorColor: UIColor) {
        if pageControl == nil { return }
        pageControl.backgroundColor = backgroundColor
        pageControl.currentPageIndicatorTintColor = currentIndicatorColor
        pageControl.pageIndicatorTintColor = indicatorColor
        pageControl.tintColor = .systemBlue
    }
    
    func setPageControllPosition(direction: PageControllDirection) {
        if pageControl == nil { return }
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            switch direction {
            case .bottomUp:
                NSLayoutConstraint.activate([
                    self.pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                    self.pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
                    self.pageControl.heightAnchor.constraint(equalToConstant: self.pageControl.frame.height)
                ])
            case .bottomDown:
                NSLayoutConstraint.activate([
                    self.pageControl.topAnchor.constraint(equalTo: self.topAnchor, constant: self.collection.frame.maxY),
                    self.pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
                    self.pageControl.heightAnchor.constraint(equalToConstant: self.pageControl.frame.height)
                ])
            default: break
            }
        }
    }

    func getDefaultImageData() -> Data? {
        let defaultImg = UIImage(systemName: "person.circle.fill")?.jpegData(compressionQuality: 0.8)
        return defaultImg
    }
}


// MARK:- Actions
extension SwipeImage {
    
    @objc func onPageChanged(_ sender: UIPageControl) {
        collection.setContentOffset(CGPoint(x: CGFloat(sender.currentPage) * self.bounds.width, y: 0), animated: true)
    }
}

extension SwipeImage: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = isUrl ? urls.count : datas.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        let imgViewTag: Int = 101
        
        func setImage(imgView: UIImageView) {
            if isUrl {
                let url = URL(string: urls[indexPath.row])!
                imgView.loadImage(url: url)
            } else {
                guard let imgData = datas[indexPath.row] else { return }
                imgView.image = UIImage(data: imgData)
            }
            imgView.contentMode = .scaleAspectFit
        }
        
        if let imgView = cell.viewWithTag(imgViewTag) as? UIImageView {
            setImage(imgView: imgView)
        } else {
            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            imgView.tintColor = .systemBlue
//            imgView.sizeToFit()
            imgView.frame.size = CGSize(width: self.frame.width, height: self.frame.height)
            imgView.frame.origin = CGPoint(x: (self.frame.width / 2) - (imgView.frame.width / 2), y: (self.frame.height / 2) - (imgView.frame.height / 2))
            setImage(imgView: imgView)
            cell.addSubview(imgView)
            imgView.tag = imgViewTag
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        _log.log("scrollViewDidEndDecelerating")
        let currentPage = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.width)))
        pageControl.currentPage = currentPage
        
    }
}
