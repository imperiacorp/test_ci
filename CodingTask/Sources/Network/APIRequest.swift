//
//  APIRequest.swift
//  CodingTask
//
//  Created by Dmitriy Gonchar on 6/27/18.
//  Copyright © 2018 Dmitriy Gonchar. All rights reserved.
//

import Foundation

enum APIRequest {

    case searchByPlace(offset: Int, limit: Int, searchText: String)

    /// Path component
    var endPoint: String {
        switch self {
        case .searchByPlace(_,_,_): return "place"
        }
    }

    /// Request type
    var httpMethod: HTTPMethod {
        switch self {
        case .searchByPlace(_,_,_): return .get
        }
    }

    var headers: [String : String]? {
        switch self {
        case .searchByPlace(_,_,_): return ["Accept": "application/json"]
        }
    }

    /// Optional HTTP body parameters.
    var bodyParams: [AnyHashable: Any]? {
        switch self {
        case .searchByPlace(let offset, let limit, let searchText):
            let queryValue = "area:\(searchText)"
            return ["query": queryValue, "limit": "\(limit)", "offset": "\(offset)"]
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
