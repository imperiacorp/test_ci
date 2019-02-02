//
//  PostsDataSource.swift
//  CodingTask
//
//  Created by Dmitriy Gonchar on 6/27/18.
//  Copyright © 2018 Dmitriy Gonchar. All rights reserved.
//

import Foundation

final class PlacesDataSource {

    typealias completionResultClosure = ([PlaceModel]?, Error?) -> ()

    // MARK: Private Vars

    private lazy var client = APIClient(baseURLString: "http://musicbrainz.org/ws/2/")

    // MARK: Public functions

    /// A function performs search Posts request and serialize returned data to models.
    /// Also this function contains all logic related to pagination
    ///
    /// - Parameters:
    ///   - searchText: String value is used for search terms
    ///   - newSearch: Bool value is used for pagination requests, default valut 'true'
    ///   - offset: Int value is used for pagination requests
    ///   - completion: Completion handler with optional array of PostModels and optional Error
    func loadData(searchText: String,
                  newSearch: Bool = true,
                  offset: Int = 0,
                  completion: @escaping completionResultClosure) {

        let searchPlaceRequest = APIRequest.searchByPlace(offset: offset,
                                                          limit: defaultResultsLimit,
                                                          searchText: searchText)

        if newSearch {
            client.stop(request: searchPlaceRequest)
        }

        client.send(request: searchPlaceRequest) { [weak self] responseResult in

            switch responseResult {
            case .result(let responseData):

                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(PlacesGeneralModel.self, from: responseData) else {
                    completion(nil, NSError.appError(type: .responseError, statusCode: allDataWasLoaded))
                    return
                }

                DispatchQueue.main.async {
                    let totalPlacesCount = result.offset + result.returnedCount
                    if totalPlacesCount < result.count {
                        self?.loadData(searchText: searchText,
                                       newSearch: false,
                                       offset: totalPlacesCount,
                                       completion: completion)
                    }
                    completion(result.places, nil)
                }

            case .error(let error):
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
}
