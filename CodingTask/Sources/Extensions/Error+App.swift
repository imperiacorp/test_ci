//
//  Error+App.swift
//  CodingTask
//
//  Created by Dmitriy Gonchar on 6/27/18.
//  Copyright © 2018 Dmitriy Gonchar. All rights reserved.
//

import Foundation

let allDataWasLoaded = 1001

extension NSError {

    enum ErrorType: String {
        case appError = "com.app.error"
        case serverError = "com.server.error"
        case responseError = "com.response.error"
        case internetConnetionError = "com.connection.error"

        func errorDescription() -> String {
            switch self {
            case .appError: return "An internal app error occured."
            case .serverError: return "Server connection error, try again later"
            case .responseError: return "Incorrect response data"
            case .internetConnetionError: return "Please check your internet connection"
            }
        }
    }

    static func appError(type: ErrorType, statusCode: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: type.errorDescription()]
        return NSError(domain: type.rawValue, code: statusCode, userInfo: userInfo)
    }
}
