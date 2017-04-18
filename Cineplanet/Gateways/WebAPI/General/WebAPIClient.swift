//
//  WebAPIClient.swift
//  Cineplanet
//
//  Created by Gustavo Villar on 4/11/17.
//  Copyright © 2017 Globant. All rights reserved.
//

import Foundation

import Alamofire
import Timberjack

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

/**
 It is a networking wrapper class to avoid direct
 dependencies with Alamofire. It is responsible for 
 creating requests to the Web API.
*/
class WebAPIClient {
    
    private static let baseURL = "https://api.themoviedb.org/3"
    private static let imgageBaseURL =  "https://image.tmdb.org/t/p/w500"
    private static let apiKey = "1f4d7de5836b788bdfd897c3e0d0a24b"
    
    let sessionManager: SessionManager
    
    init() {
        let configuration = Timberjack.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10 // seconds
        configuration.timeoutIntervalForResource = 10 // seconds
        sessionManager = SessionManager(configuration: configuration)
    }
    
    @discardableResult
    func request(_ method: HTTPMethod, path: String, headers: [String: String]? = nil, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any]? = nil, completion: @escaping (Result<Any>) -> Void) -> WebAPIRequest {
        
        var apiQueryParameters = queryParameters ?? [:]
        apiQueryParameters["api_key"] = WebAPIClient.apiKey
        
        let url = WebAPIURLBuilder.url(forPath: WebAPIClient.baseURL + path, queryParameters: apiQueryParameters)
        let alamofireHTTPMethod = Alamofire.HTTPMethod(rawValue: method.rawValue)!

        let request = sessionManager.request(url, method: alamofireHTTPMethod, parameters: bodyParameters, encoding: JSONEncoding.default, headers: headers)
        
        request.responseJSON { (dataResponse) in

           // TODO: Handle API Error
//            if let responseValue = dataResponse.value,
//                let apiError = self.getAPIError(fromResponse: responseValue) {
//                completion(.failure(apiError))
//            } else
            if let alamofireError = dataResponse.error as? AFError,
                case .responseSerializationFailed(let reason) = alamofireError,
                case .inputDataNilOrZeroLength = reason {
                completion(.success(Void.self))
            } else {
                completion(Result(dataResponse.result))
            }
        }
        
        return WebAPIRequest(request)
        
    }
    
    @discardableResult
    func authenticatedRequest(_ method: HTTPMethod, path: String, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any]? = nil, token: String, completion: @escaping (Result<Any>) -> Void) -> WebAPIRequest {
        
        let headers: [String: String] = [
            "AndroidVersion": "55",
            "x-access-token": token
        ]
        
        return self.request(method, path: path, headers: headers, queryParameters: queryParameters, bodyParameters: bodyParameters, completion: completion)
        
    }
    
}

// MARK: Init Result from Alamofire.Result
extension Result {
    
    /**
     Converts `Alamofire.Result` to `Inkafarma.Result`
     to avoid `Alamofire` dependency
     
     - parameter result: Alamofire.Result
     */
    init(_ result: Alamofire.Result<Value>) {
        switch result {
        case .success(let value): self = .success(value)
        case .failure(let error): self = .failure(error)
        }
    }
    
}