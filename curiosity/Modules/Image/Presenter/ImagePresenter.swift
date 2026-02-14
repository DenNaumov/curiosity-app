//
//  ImagePresenter.swift
//  curiosity
//
//  Created on 10/08/2019.
//  Copyright © 2019 Денис Наумов. All rights reserved.
//

import  UIKit

class ImagePresenter: ImagePresenterAssemblyProtocol {

    weak var viewController: ImagePresenterToViewProtocol?
    var interactor: ImagePresenterToInteractorProtocol?
    var router: ImagePresenterToRouterProtocol?
    let imageFile: ImageFile
    
    init(imageFile: ImageFile) {
        self.imageFile = imageFile
    }
}

extension ImagePresenter: ImageViewToPresenterProtocol {
    func readyToShow() {
        viewController?.showImage(from: imageFile)
    }
}

extension ImagePresenter: ImageInteractorToPresenterProtocol {

}
