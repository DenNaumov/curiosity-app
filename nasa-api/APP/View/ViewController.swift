//
//  ViewController.swift
//  nasa-api
//
//  Created by Денис Наумов on 17.08.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource = [CuriosityPhoto]()
    
    private let controller = CollectionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        Task {
            do {
                let response = try await controller.fetchData()
                self.dataSource = response.photos
                self.collectionView.reloadData()
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.addLoadingIndicator()
        
        let photo = dataSource[indexPath.row]
        Task {
            do {
                let data = try await controller.fetchImage(for: photo.remoteURL)
                if let currentCell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                    currentCell.deleteLoadingIndicator()
                    currentCell.setImage(data: data)
                }
            } catch {
                print("Error loading image for index \(indexPath.row): \(error)")
                if let currentCell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                    currentCell.deleteLoadingIndicator()
                }
            }
        }
        
        return cell
    }
}
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: 100)
    }
}
