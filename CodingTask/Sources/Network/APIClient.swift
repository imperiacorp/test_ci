//
//  APIClient.swift
//  CodingTask
//
//  Created by Dmitriy Gonchar on 6/27/18.
//  Copyright © 2018 Dmitriy Gonchar. All rights reserved.
//

import UIKit

enum RequestResult<T> {
    case result(T)
    case error(Error)
}

final class APIClient {

    typealias completionEnumClosure = (RequestResult<Data>) -> ()

    var baseURLString: String
    
    // MARK: Public functions

    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }

    /// A generic function used for sending an API requests.
    ///
    /// - Parameters:
    ///   - request: APIRequest instance containing the request data.
    ///   - completion: Completion handler with RequestResult which can contain result Data or Error
    func send(request: APIRequest, completion: @escaping completionEnumClosure) {

        guard Reachability.isConnectedToNetwork() else {
            let error = NSError.appError(type: .internetConnetionError, statusCode: 0)
            completion(.error(error))
            return
        }

        guard let url = createURL(for: request) else {
            let error = NSError.appError(type: .appError, statusCode: 0)
            completion(.error(error))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue

        if let headers = request.headers {
            urlRequest.allHTTPHeaderFields = headers
        }

        if let paramaters = request.bodyParams,
            let bodyData = try? JSONSerialization.data(withJSONObject: paramaters, options: .init(rawValue: 0)),
            request.httpMethod != .get {
            urlRequest.httpBody = bodyData
        }

        // Initialize and send the request.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in

            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }

            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled { return }
                completion(.error(NSError.appError(type: .serverError, statusCode: (error as NSError).code)))
                return
            }

            guard let responseData = data else {
                completion(.error(NSError.appError(type: .responseError, statusCode: 0)))
                return
            }

            completion(.result(responseData))
        })
        dataTask.resume()
    }

    /// A function used for stopping an API requests.
    ///
    /// - Parameters:
    ///   - request: APIRequest instance containing the request data.
    func stop(request: APIRequest) {
        URLSession.shared.getAllTasks { tasks in
            tasks.forEach({ task in
                guard let URLString = task.originalRequest?.url?.absoluteString else { return }
                let contains = URLString.contains(request.endPoint)
                if task.state == .running && contains {
                    task.cancel()
                }
            })
        }
    }

    // MARK: Private functions

    /// A function used for constructing URL for API requests.
    ///
    /// - Parameters:
    ///   - request: APIRequest instance containing the request data.
    /// - Returns:
    ///   - optional URL object
    func createURL(for request: APIRequest) -> URL? {

        let fullURLPath = baseURLString + request.endPoint

        if request.httpMethod == .get {
            let urlComp = NSURLComponents(string: fullURLPath)!
            guard let params = request.bodyParams else {
                return urlComp.url
            }

            var items = [URLQueryItem]()

            for (key,value) in params {
                if let keyString = key as? String, let valueString = value as? String {
                    let valueWithPercentEncoding = valueString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    items.append(URLQueryItem(name: keyString, value: valueWithPercentEncoding))
                }
            }

            if !items.isEmpty {
                urlComp.queryItems = items
            }
            return urlComp.url
        } else {
            return URL(string: fullURLPath)
        }
    }
}
