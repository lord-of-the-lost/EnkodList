//
//  NetworkService.swift
//  EnkodList
//
//  Created by Николай Игнатов on 14.07.2023.
//

import Foundation

// MARK: - NetworkServiceProtocol

protocol NetworkServiceProtocol {
    func fetchData(completion: @escaping (Result<Data, Error>) -> ())
}

// MARK: - NetworkError

enum NetworkError: Error {
    case badURL, badRequest, badResponse, invalidData
}

// MARK: - NetworkService

final class NetworkService: NetworkServiceProtocol {
    
    private let urlString = "https://run.mocky.io/v3/956d7c43-b513-4698-aa7d-6a9bfd4f1bec"
    
    func fetchData(completion: @escaping (Result<Data, Error>) -> ()) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                }
                return
            }
            completion(.success(data))
        }.resume()
    }
}
