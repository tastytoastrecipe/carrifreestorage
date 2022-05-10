//
//  BannerItem.swift
//  TestProject
//
//  Created by plattics-kwon on 2021/10/21.
//

import UIKit

class BannerItem: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    
    private var imgUrl: String = ""
    private var pageUrl: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func configure() {
        self.clipsToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.1
        
        img.layer.masksToBounds = false
    }
    
    func configure(imgUrl: String, pageUrl: String, loadCompletion: ((Data?) -> Void)? = nil) {
        configure()
        setImage(imgUrl: imgUrl, loadCompletion: loadCompletion)
        setPage(pageUrl: pageUrl)
    }
    
    func configure(data: Data?, pageUrl: String) {
        configure()
        setImage(data: data)
        setPage(pageUrl: pageUrl)
    }
    
    func setImage(imgUrl: String, loadCompletion: ((Data?) -> Void)? = nil) {
        if imgUrl.isEmpty { return }
        if self.imgUrl == imgUrl { return }
        self.imgUrl = imgUrl
        
        img.loadImage(url: imgUrl) {
            let imgData = self.img.image?.pngData()
            loadCompletion?(imgData)
        }
    }
    
    func setImage(data: Data?) {
        guard let data = data else { return }
        self.img.image = UIImage(data: data)
    }
    
    func setPage(pageUrl: String) {
        if pageUrl.isEmpty { return }
        if self.pageUrl == pageUrl { return }
        self.pageUrl = pageUrl
    }
}
