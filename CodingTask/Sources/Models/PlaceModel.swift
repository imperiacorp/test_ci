//
//  PlaceModel.swift
//  CodingTask
//
//  Created by Dmitriy Gonchar on 6/27/18.
//  Copyright © 2018 Dmitriy Gonchar. All rights reserved.
//

import Foundation
import CoreLocation

struct PlaceModel: Decodable {

    let objectId: String
    let address: String?
    let name: String
    let coordinate: CLLocationCoordinate2D?
    let begin: Int?
    let ended: Bool?
    var counter: Int = 0

    enum CodingKeys: String, CodingKey
    {
        case objectId = "id"
        case address = "address"
        case name = "name"
        case coordinates = "coordinates"
        case lat = "latitude"
        case lng = "longitude"
        case lifeSpan = "life-span"
        case begin = "begin"
        case ended = "ended"
    }

    init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        objectId = try values.decode(String.self, forKey: .objectId)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        name = try values.decode(String.self, forKey: .name)

        if let coordinates = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .coordinates),
            let lat = try coordinates.decodeIfPresent(String.self, forKey: .lat),
            let lng = try coordinates.decodeIfPresent(String.self, forKey: .lng),
            let latitude = Double(lat),
            let longitude = Double(lng) {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            coordinate = nil
        }

        let lifeSpan = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .lifeSpan)
        let beginDateString = try lifeSpan.decodeIfPresent(String.self, forKey: .begin)
        if let yearStringValue = beginDateString?.components(separatedBy: "-").first, let year = Int(yearStringValue) {
            begin = year
        } else {
            begin = nil
        }

        ended = try lifeSpan.decodeIfPresent(Bool.self, forKey: .ended)
    }
}

extension PlaceModel: Hashable {

    static func == (lhs: PlaceModel, rhs: PlaceModel) -> Bool {
        return lhs.objectId == rhs.objectId
    }

    var hashValue: Int {
        return objectId.hashValue ^ name.hashValue
    }
}

