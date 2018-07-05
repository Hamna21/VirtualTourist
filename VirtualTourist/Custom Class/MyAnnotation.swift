//
//  MyAnnotation.swift
//  VirtualTourist
//
//  Created by Hamna Usmani on 7/2/18.
//  Copyright © 2018 Hamna Usmani. All rights reserved.
//

import MapKit
import CoreData

class MyAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var pin: Pin?
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}
