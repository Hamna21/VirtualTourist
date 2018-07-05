//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Hamna Usmani on 7/1/18.
//  Copyright © 2018 Hamna Usmani. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var pins = [Pin]()
    var annotations = [MyAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.setToolbarHidden(true, animated: false)
        
        mapView.delegate = self
        performFetchRequest()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    //Adding gesture recognizer to recognize addition of pin on map
    func addGestureRecognizer(){
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        longGesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longGesture)
    }
    
    //Fetching pins from storage
    func performFetchRequest(){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        dataController.viewContext.perform {
            if let results = try? self.dataController.viewContext.fetch(fetchRequest){
                self.pins = results
                self.addAnnotations()
            }
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    //Adding user tapped location (annotation) on map
    @objc func addAnnotation(_ longGesture: UIGestureRecognizer){
        let touchPoint = longGesture.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MyAnnotation(coordinate: coordinate)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        addPinToStorage(coordinate: coordinate, annotation: annotation)
    }
    
    //Saving user added pin to storage
    func addPinToStorage(coordinate: CLLocationCoordinate2D, annotation: MyAnnotation){
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        
        dataController.viewContext.perform {
            try? self.dataController.viewContext.save()
            annotation.pin = pin
        }
    }
    
    // Attributes of each Pin on Map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }else{
            pinView!.annotation = annotation
        }
        return pinView
    }
    
     //Action on Pin Tapped
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        let annotation = view.annotation as! MyAnnotation
        let pinOfPhotos = annotation.pin
        performSegue(withIdentifier: "locationPhotos", sender: pinOfPhotos)
    }
    
    
    
    //Adding pins to map from storage
    func addAnnotations(){
        for pin in pins {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MyAnnotation(coordinate: coordinate)
            annotation.coordinate = coordinate
            annotation.pin = pin
        
            annotations.append(annotation)
            mapView.addAnnotations(annotations)
            
        }
    }
}

extension MapViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoAlbumViewController {
            vc.pin = sender as! Pin
            vc.dataController = dataController
        }
    }
}

