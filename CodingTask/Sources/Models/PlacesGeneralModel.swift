//
//  PlacesGeneralModel.swift
//  CodingTask
//
//  Created by Dmitriy Gonchar on 6/27/18.
//  Copyright © 2018 Dmitriy Gonchar. All rights reserved.
//

import Foundation

struct PlacesGeneralModel: Decodable {

    let count: Int
    let offset: Int
    let places: [PlaceModel]
    let returnedCount: Int

    enum CodingKeys: String, CodingKey
    {
        case count = "count"
        case offset = "offset"
        case places = "places"
    }

    init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        count = try values.decode(Int.self, forKey: .count)
        offset = try values.decode(Int.self, forKey: .offset)

        var placesContainer = try values.nestedUnkeyedContainer(forKey: CodingKeys.places)
        var unparsedPlacesArray = placesContainer
        var placesArray = [PlaceModel]()
        while !placesContainer.isAtEnd {
            let _ = try placesContainer.nestedContainer(keyedBy: PlaceModel.CodingKeys.self)
            let placeModel = try unparsedPlacesArray.decode(PlaceModel.self)
            if placeModel.coordinate != nil, let beginYear = placeModel.begin, beginYear >= defaultOpeningYear { placesArray.append(placeModel) }
        }
        returnedCount = placesContainer.count ?? 0
        places = placesArray
    }
}
