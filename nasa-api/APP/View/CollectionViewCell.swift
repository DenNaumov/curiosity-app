//
//  CollectionViewCell.swift
//  nasa-api
//
//  Created by Денис Наумов on 18.08.2022.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    private weak var loadingIndicator: UIActivityIndicatorView?
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 13
        clipsToBounds = true
        
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func addLoadingIndicator() {
        if loadingIndicator == nil {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.center = contentView.center
            indicator.startAnimating()
            contentView.addSubview(indicator)
            loadingIndicator = indicator
        }
    }
    
    func deleteLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
    }
    
    func setImage(data: Data) {
        imageView.image = UIImage(data: data)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        deleteLoadingIndicator()
    }
}
