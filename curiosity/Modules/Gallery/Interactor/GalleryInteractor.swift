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
//    private var downloadImagesLeft = 0
    private var currentPage = 1
    private var pageFiles: [URL] = []
}

extension GalleryInteractor: GalleryPresenterToInteractorProtocol {

    func fetchFirstPageImageList() {
        let url = host + "?" + getParamsString(page: 1)
        AF.request(url).responseData(completionHandler: handleImageListFetching)
    }

    func fetchNextPageImageList() {
        currentPage += 1
        pageFiles = []
        let url = host + "?" + getParamsString(page: currentPage)
        AF.request(url).responseData(completionHandler: handleImageListFetching)
//        Alamofire.request(url).responseDecodable(of: ServerResponse.self)
        
    }

    func loadSavedImages() {
//        var imageFiles: [ImageFile] = []
//        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        for fileName in pageFiles {
//            let fileURL = URL(fileURLWithPath: fileName, relativeTo: documentDirectory)
//            let imageFile = ImageFile(from: fileURL)
//            imageFiles.append(imageFile)
//        }
//        if currentPage == 1 {
        presenter?.didFinishDownloadInitialImages(pageFiles.map({ url in
            return ImageFile(from: url)
        }))
//        } else {
//            presenter?.didFinishDownloadUpdate(imageFiles)
//        }
    }

    func loadOfflineImages() {
        debugPrint("failed load data")
//        do {
//            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let filesInDocuments = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
//            let images = filesInDocuments.map { (url) -> ImageFile in
//                 return ImageFile(from: url)
//             }
//            presenter?.didLoadSavedImages(images)
//        } catch {
//            print(error)
//        }
    }

    private func getParamsString(page: Int) -> String {
        var httpParams = params
        httpParams["page"] = page
        let paramsString = httpParams.map { (key, value) in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        return paramsString
    }

    private func handleImageListFetching(response: AFDataResponse<Data>) {
        switch response.result {
        case .success(let value):
            do {
                let responseData: ServerResponse = try JSONDecoder().decode(ServerResponse.self, from: value)
                self.handleImageListSuccessfullyRetrieved(responseData.photos)
            } catch {
                print(error)
                self.handleImageListFetchingFailed()
            }
        case .failure(_):
            self.handleImageListFetchingFailed()
        }
    }

    private func handleImageListSuccessfullyRetrieved(_ photoList: [CuriosityPhoto]) {
//        downloadImagesLeft = photoList.count
        for image in photoList {
            downloadImage(image)
        }
        loadSavedImages()
    }

    private func handleImageListFetchingFailed() {
        if currentPage == 1 {
            loadOfflineImages()
        }
    }
    
    private func handleImageDownload(response: DataResponse<Data, Error>) -> Void {
//        print(response.result)
    }

    private func downloadImage(_ photo: CuriosityPhoto) {
        let url = photo.remoteURL

        self.pageFiles.append(url)
//        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            fatalError()
//        }

    }

    private func downloadObject(from url: URL, completion: @escaping (URL?, URLResponse?, Error?) -> ()) {
        URLSession.shared.downloadTask(with: url, completionHandler: completion).resume()
    }

    private func moveItemToDocuments(at: URL, to: String) throws {
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        try fileManager.moveItem(at: at, to: documentDirectory.appendingPathComponent(to))
    }

//    private func downloadImageFinished() {
//        downloadImagesLeft -= 1
//        if downloadImagesLeft == 0 {
//            loadSavedImages()
//        }
//    }
}


//        request(url).responseData(completionHandler: handleImageDownload)
//        download(url).responseData(queue: .main, completionHandler: handleImageDownload)
//        download("https://httpbin.org/image/png").responseData { response in
//            debugPrint(response)
//            if let data = response.result.value {
//                let image = UIImage(data: data)
//                print(image)
//            } else {
//                print("Data was invalid")
//            }
//        }
//        downloadObject(from: url) { [unowned self] location, response, error in
//            guard let location = location else {
//                print("download error")
//                return
//            }
//            do {
//                DispatchQueue.main.async() {
//                    self.downloadImageFinished()
//                }
//                let filename = response?.suggestedFilename ?? url.lastPathComponent
//                self.pageFiles.append(filename)
//                try self.fileManager.moveItem(at: location, to: documentDirectory.appendingPathComponent(filename))
//            } catch {
//                print(error)
//            }
//        }
