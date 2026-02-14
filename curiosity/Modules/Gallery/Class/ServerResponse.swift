//
//  ApiResponse.swift
//  curiosity
//
//  Created by user156854 on 8/17/19.
//  Copyright © 2019 Денис Наумов. All rights reserved.
//

import UIKit

struct ServerResponse: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case photos
    }
    let photos: [CuriosityPhoto]
}
