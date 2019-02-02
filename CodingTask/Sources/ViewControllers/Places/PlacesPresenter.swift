//
//  PlacesPresenter.swift
//  CodingTask
//
//  Created by Dmitriy Gonchar on 6/27/18.
//  Copyright © 2018 Dmitriy Gonchar. All rights reserved.
//

import Foundation
import MapKit

protocol PlacesView: class {
    func reloadView(with annotations: [PlaceAnnotation])
    func removeFromView(by type: PlacesPresenter.RemoveAnnotationType)
    func showAlert(with error: Error)
}

class PlacesPresenter {

    enum RemoveAnnotationType {
        case all
        case partly([PlaceAnnotation])
    }

    fileprivate(set) weak var placesView: PlacesView?
    private let dataSource = PlacesDataSource()
    private var mainTimer: RepeatingTimer?
    private var places: [PlaceModel]?

    // MARK: Public

    init(placesView: PlacesView) {
        self.placesView = placesView
    }

    /// A function calls loading data and serializes it to view PlacesViewModel
    /// Also it calls update view state methods reloadView(with:) or showAlert(with:)
    ///
    /// - Parameters:
    ///   - searchText: String value is used for search terms
    func loadData(searchText: String) {

        clearData()
        dataSource.loadData(searchText: searchText) { [weak self] (places, error) in
            guard let `self` = self else { return }
            if let places = places {
                if self.places == nil {
                    self.places = places
                    self.createAndStartTimer()
                } else {
                    let uniqueFilteredPlaces = Array(Set(self.places! + places))
                    self.places = uniqueFilteredPlaces
                }
                let placesModels = self.convert(models: places)
                self.placesView?.reloadView(with: placesModels)
            } else if let error = error {
                self.placesView?.showAlert(with: error)
            }
        }
    }

    // MARK: Private

    /// A function increases counter for stored models
    /// This is necessary for the logic of the timer
    private func increaseCounterValue() {
        let increasedPlaces = places?.map({ model -> PlaceModel in
            var place = model
            place.counter += 1
            return place
        })
        guard let updatedPlaces = increasedPlaces else { return }
        places = updatedPlaces
    }

    /// A function clears stored and view data, removes timer
    private func clearData() {
        places = nil
        removeTimer()
        placesView?.removeFromView(by: .all)
    }

    /// A function converts PlaceModels to MKAnnotation models
    private func convert(models: [PlaceModel]) -> [PlaceAnnotation] {
        return models.map({ model -> PlaceAnnotation? in
            guard let coordinates = model.coordinate else { return nil }
            let annotation = PlaceAnnotation(placeId: model.objectId,
                                             title: model.name,
                                             locationName: model.address,
                                             coordinate: coordinates)
            return annotation
        }).compactMap({ $0 })
    }

    // MARK: Timer part

    /// A function creates and starts timer
    /// Also it contains Lifespan logic
    private func createAndStartTimer() {
        let timer = RepeatingTimer(timeInterval: 1.0, type: .main)
        timer.eventHandler = { [weak self] in

            guard let `self` = self else { return }
            guard let storedPlaces = self.places, storedPlaces.count > 0 else {
                self.mainTimer = nil
                return
            }

            self.increaseCounterValue()
            let modelsToRemove = self.places?.map({ placeModel -> PlaceModel? in
                guard let beginYear = placeModel.begin else { return placeModel }
                return beginYear - defaultOpeningYear < placeModel.counter ? placeModel : nil
            }).compactMap({ $0 })

            guard let models = modelsToRemove, models.count > 0 else { return }

            let updatedPlaces = Array(Set(storedPlaces).subtracting(models))
            self.places = updatedPlaces
            let placesModels = self.convert(models: updatedPlaces)
            self.placesView?.removeFromView(by: .partly(placesModels))
        }
        timer.start()
        mainTimer = timer
    }

    /// A function removes timer
    private func removeTimer() {
        mainTimer = nil
    }
}
