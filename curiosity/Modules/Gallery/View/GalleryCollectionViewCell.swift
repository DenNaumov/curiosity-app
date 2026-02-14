//
//  CollectionViewCell.swift
//  maps
//
//  Created by Денис Наумов on 05/08/2019.
//  Copyright © 2019 Денис Наумов. All rights reserved.
//

import UIKit
import Alamofire

class GalleryCollectionViewCell: UICollectionViewCell {

    var imageView: UIImageView? = nil
    var title: UILabel? = nil

    func setup(with image: ImageFile) {
        let url = image.url
        AF.request(url).responseData(completionHandler: handleImageDownload)
        self.title = UILabel()
    }
    
    private func handleImageDownload(response: AFDataResponse<Data>) -> Void {
        let image = UIImage(data: response.data! as Data)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
        }
        self.imageView = imageView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.removeFromSuperview()
        if let gestureRecognizer = gestureRecognizers?.first {
            removeGestureRecognizer(gestureRecognizer)
        }
    }
}
