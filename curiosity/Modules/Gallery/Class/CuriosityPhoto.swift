//
//  CuriosityPhoto.swift
//  curiosity
//
//  Created by Денис Наумов on 15.05.2022.
//  Copyright © 2022 Денис Наумов. All rights reserved.
//

import Foundation

struct CuriosityPhoto: Decodable {
    let id: Int
    let remoteURL: URL
    let date: Date
    let camera: CuriosityCamera
//    let rover: CuriosityRover
    
    enum CodingKeys: String, CodingKey {
        case id
        case remoteURL = "img_src"
        case date = "earth_date"
        case camera
//        case rover
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(Int.self, forKey: .id)
        let dateString = try values.decode(String.self, forKey: .date)
        date = DateFormatter().getISODate(dateString: dateString)
        remoteURL = try values.decode(URL.self, forKey: .remoteURL)
        camera = try values.decode(CuriosityCamera.self, forKey: .camera)
    }
}

private extension DateFormatter {
    
    func getISODate(dateString: String) -> Date {
        dateFormat = "yyyy-MM-dd"
        return date(from: dateString)!
    }
}
