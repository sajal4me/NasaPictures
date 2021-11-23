//
//  Networking.swift
//  Pictures
//
//  Created by Sajal Gupta on 21/11/21.
//

import Foundation

internal final class Networking {
    
    internal func request<T: Decodable>(endpoint: Endpoint, decoder: JSONDecoder = JSONDecoder(), onCompletion: @escaping (Result<T, NetworkError>) -> Void )  {
        
        var component = URLComponents()
        component.scheme = endpoint.scheme
        component.host = endpoint.baseURL
        component.path = endpoint.path
        component.queryItems = endpoint.parameters
        
        guard let url = component.url else {
            onCompletion(.failure(.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            
            if let unwrappedError = error {
                onCompletion(.failure(.custom(unwrappedError.localizedDescription)))
                return
            }
            
            guard response != nil, let data = data else {
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    onCompletion(.success(decodedObject))
                } catch {
                    onCompletion(.failure(.custom(error.localizedDescription)))
                }
            }
        }
        
        dataTask.resume()
    }
}
