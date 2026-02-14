//
//  NetworkService.swift
//  nasa-api
//
//  Created by Денис Наумов on 18.08.2022.
//

import Foundation

class NetworkService {

    func request(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    func requestJson<T: Decodable>(from urlString: String, using type: T.Type) async throws -> T {
        let data = try await request(from: urlString)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
