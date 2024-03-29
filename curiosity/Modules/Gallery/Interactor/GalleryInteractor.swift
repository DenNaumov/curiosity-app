//
//  GalleryInteractor.swift
//  curiosity
//
//  Created on 10/08/2019.
//  Copyright © 2019 Денис Наумов. All rights reserved.
//

import Alamofire
import Foundation

class GalleryInteractor: GalleryInteractorAssemblyProtocol {
    weak var presenter: GalleryInteractorToPresenterProtocol?
    private let host = "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos"
    private let params: [String: Any] = ["sol": 100, "api_key": "DEMO_KEY"]
    private let fileManager = FileManager.default
    private var downloadImagesLeft = 0
    private var currentPage = 1
    private var pageFiles: [String] = []
}

extension GalleryInteractor: GalleryPresenterToInteractorProtocol {

    func fetchFirstPageImageList() {
        let url = host + "?" + getParamsString(page: 1)
        request(url).responseData(completionHandler: handleImageListFetching)
    }

    func fetchNextPageImageList() {
        currentPage += 1
        pageFiles = []
        let url = host + "?" + getParamsString(page: currentPage)
        request(url).responseData(completionHandler: handleImageListFetching)
    }

    func loadSavedImages() {
        var imageFiles: [ImageFile] = []
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for fileName in pageFiles {
            let fileURL = URL(fileURLWithPath: fileName, relativeTo: documentDirectory)
            let imageFile = ImageFile(from: fileURL)
            imageFiles.append(imageFile)
        }
        if currentPage == 1 {
            presenter?.didFinishDownloadInitialImages(imageFiles)
        } else {
            presenter?.didFinishDownloadUpdate(imageFiles)
        }
    }

    func loadOfflineImages() {
        do {
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filesInDocuments = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            let images = filesInDocuments.map { (url) -> ImageFile in
                 return ImageFile(from: url)
             }
            presenter?.didLoadSavedImages(images)
        } catch {
            print(error)
        }
    }

    private func getParamsString(page: Int) -> String {
        var httpParams = params
        httpParams["page"] = page
        let paramsString = httpParams.map { (key, value) in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        return paramsString
    }

    private func imageListRetrieveHandler(response: DataResponse<Data>) {
        switch response.result {
        case .success(let value):
            let responseData: ServerResponseData = try! JSONDecoder().decode(ServerResponseData.self, from: value)
            self.imageListRetrieved(responseData.photos)
        case .failure(_):
            if currentPage == 1 {
                self.loadOfflineImages()
            }
        }
    }

    private func imageListRetrieved(_ imageList: [CuriosityPhoto]) {
        downloadImagesLeft = imageList.count
        for image in imageList {
            downloadImage(image)
        }
    }

    private func downloadImage(_ imageData: CuriosityPhoto) {
        let url = imageData.remoteURL
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        fetchData(from: url) { [unowned self] location, response, error in
            guard let location = location else {
                print("download error")
                return
            }
            do {
                DispatchQueue.main.async() {
                    self.downloadImageFinished()
                }
                let filename = response?.suggestedFilename ?? url.lastPathComponent
                self.pageFiles.append(filename)
                try self.fileManager.moveItem(at: location, to: documentDirectory.appendingPathComponent(filename))
            } catch {
                print(error)
            }
        }
    }

    private func fetchData(from url: URL, completion: @escaping (URL?, URLResponse?, Error?) -> ()) {
        URLSession.shared.downloadTask(with: url, completionHandler: completion).resume()
    }

    private func moveItemToDocuments(at: URL, to: String) throws {
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        try fileManager.moveItem(at: at, to: documentDirectory.appendingPathComponent(to))
    }

    private func downloadImageFinished() {
        downloadImagesLeft -= 1
        if downloadImagesLeft == 0 {
            loadSavedImages()
        }
    }    
}
