//
//  ImageRouter.swift
//  curiosity
//
//  Created on 10/08/2019.
//  Copyright © 2019 Денис Наумов. All rights reserved.
//

import UIKit

class ImageRouter {

    static func createModule(with imageFile: ImageFile) -> UIViewController {

        let viewController = ImageViewController()

        let presenter = ImagePresenter(imageFile: imageFile)
        let interactor = ImageInteractor()
        let router = ImageRouter()

        viewController.presenter = presenter
        presenter.viewController = viewController
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter

        return viewController
    }
}

extension ImageRouter: ImagePresenterToRouterProtocol {

}
