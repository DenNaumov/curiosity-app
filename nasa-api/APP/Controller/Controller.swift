//
//  Controller.swift
//  nasa-api
//
//  Created by Денис Наумов on 18.08.2022.
//

import UIKit

class CollectionController {
    
    let network = NetworkService()
    
    func fetchData() async throws -> ServerResponse {
        let url = "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=100&api_key=DEMO_KEY"
        return try await network.requestJson(from: url, using: ServerResponse.self)
    }
    
    func fetchImage(for url: URL) async throws -> Data {
        return try await network.request(from: url.absoluteString)
    }
}
