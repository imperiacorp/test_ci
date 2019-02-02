//
//  PlacesViewController.swift
//  CodingTask
//
//  Created by Dmitriy Gonchar on 6/27/18.
//  Copyright © 2018 Dmitriy Gonchar. All rights reserved.
//

import UIKit
import MapKit

class PlacesViewController: UIViewController {

    // MARK: Vars

    @IBOutlet weak var mapView: MKMapView!

    private var presenter : PlacesPresenter!
    var searchBarCntrl: UISearchController?

    // MARK: - Base

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = PlacesPresenter(placesView: self)

        baseSetup()
    }

    func baseSetup() {

        title = "Music Brainz"

        mapView.delegate = self

        searchBarSetup()
    }

    func searchBarSetup() {

        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Places"
        searchBarCntrl = searchController

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            searchController.hidesNavigationBarDuringPresentation = false
            navigationItem.titleView = searchBarCntrl?.searchBar
        }
        definesPresentationContext = true
    }
}

// MARK: UISearchBarDelegate
extension PlacesViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, searchText.count >= minimumSearchTextLength else {
            return
        }
        presenter.loadData(searchText: searchText)
    }
}

// MARK: PlacesView protocol
extension PlacesViewController: PlacesView {

    func reloadView(with annotations: [PlaceAnnotation]) {
        mapView.addAnnotations(annotations)
    }

    func removeFromView(by type: PlacesPresenter.RemoveAnnotationType) {
        switch type {
        case .partly(let annotations):
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(annotations)
        default:
            mapView.removeAnnotations(mapView.annotations)
        }
    }

    func showAlert(with error: Error) {
        let alert = UIAlertController.app_alert(forError: error)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: MKMapViewDelegate
extension PlacesViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard let annotation = annotation as? PlaceAnnotation else { return nil }

        let identifier = String(describing: PlaceAnnotation.self)
        var view: MKAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.image = #imageLiteral(resourceName: "map_pin")
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}
