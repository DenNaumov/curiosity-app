//
//  ServerResponse.swift
//  nasa-api
//
//  Created by Денис Наумов on 17.08.2022.
//

import Foundation
//import UIKit

struct ServerResponse: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case photos
    }
    let photos: [CuriosityPhoto]
}

struct CuriosityPhoto: Decodable {
    let id: Int
    let remoteURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case remoteURL = "img_src"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        let url  = try values.decode(URL.self, forKey: .remoteURL)
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw DecodingError.dataCorruptedError(forKey: .remoteURL, in: values, debugDescription: "Invalid URL components")
        }
        urlComponents.scheme = "https"
        guard let secureURL = urlComponents.url else {
            throw DecodingError.dataCorruptedError(forKey: .remoteURL, in: values, debugDescription: "Could not create secure URL")
        }
        remoteURL = secureURL
    }
}
