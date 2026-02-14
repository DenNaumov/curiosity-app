//
//  GalleryEntity.swift
//  curiosity
//
//  Created on 10/08/2019.
//  Copyright © 2019 Денис Наумов. All rights reserved.
//

import Foundation

class ImageFile {

    private let content: NSData? = nil
    let url: URL

    init(from url: URL) {
        self.url = url
    }
    
    public func getContent() -> NSData {
        return content!
    }
}
