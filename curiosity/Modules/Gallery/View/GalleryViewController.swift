//
//  GalleryViewController.swift
//  curiosity
//
//  Created on 10/08/2019.
//  Copyright © 2019 Денис Наумов. All rights reserved.
//

import UIKit
import SnapKit

class GalleryViewController: UIViewController, GalleryViewAssemblyProtocol {

    var presenter: GalleryViewToPresenterProtocol?

    private let reuseIdentifier = "reuseIdentifier"
    private var dataSourceFiles: [ImageFile] = []

    private var collectionView: UICollectionView!
    private var loadingIndicator: UIActivityIndicatorView!
    private var updatingIndicator: UIActivityIndicatorView!
    
    struct Appearance {
        static let cellHeight = 250
        static let cellWidth = 150
        static let updateIndicatorBottomInset = 30
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupIndicator()
        presenter?.readyToShow()
    }

    private func setupIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator?.startAnimating()
        view.addSubview(loadingIndicator)
        loadingIndicator?.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.sectionHeadersPinToVisibleBounds = true
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.center.width.height.equalToSuperview()
        }

        updatingIndicator = UIActivityIndicatorView(style: .large)
        view.addSubview(updatingIndicator)
        updatingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(Appearance.updateIndicatorBottomInset)
        }
    }
}

extension GalleryViewController: GalleryPresenterToViewProtocol {

    func showUpdateIndicator() {
        updatingIndicator.startAnimating()
    }
    
    func hideUpdateIndicator() {
        updatingIndicator.stopAnimating()
    }

    func initiateGallery(_ files: [ImageFile]) {
        dataSourceFiles = files
        setupCollectionView()
    }

    func addToGallery(_ files: [ImageFile]) {
        let lastFilesCount = dataSourceFiles.count
        let newFilesCount = files.count
        let actualFilesCount = lastFilesCount + newFilesCount
        var indexes: [IndexPath] = []
        for i in lastFilesCount...(actualFilesCount - 1) {
            indexes.append(IndexPath(item: i, section: 0))
        }
        dataSourceFiles.append(contentsOf: files)
        collectionView?.insertItems(at: indexes)
    }

    func removeItemFromGallery(at indexPath: IndexPath) {
        dataSourceFiles.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
    }

    func initiateGalleryOffline(_ imageFiles: [ImageFile]) {
        dataSourceFiles = imageFiles
        setupCollectionView()
    }

    func showErrorMessage(_ text: String) {
        loadingIndicator.stopAnimating()
        let label = UILabel(frame: .zero)
        label.text = text
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Appearance.cellWidth, height: Appearance.cellHeight)
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceFiles.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GalleryCollectionViewCell
        
        cell.backgroundColor = .white
        cell.setup(with: dataSourceFiles[indexPath.row])
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
        longPressRecognizer.minimumPressDuration = 1.0
        cell.addGestureRecognizer(longPressRecognizer)
        
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageFile = dataSourceFiles[indexPath.row]
        presenter?.openImage(imageFile)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            presenter?.didScrollToBottom()
        }
    }
}

extension GalleryViewController {
    
    @objc func longPressHandler(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == .began {
            let pressLocation = gestureReconizer.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: pressLocation) {
                presenter?.didLongPressOnItem(at: indexPath)
            }
        }
    }
}
