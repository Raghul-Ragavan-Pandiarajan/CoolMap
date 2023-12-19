//
//  AnnotationModal.swift
//  CoolMap
//
//  Created by Raghul Ragavan on 07/04/23.
//

import Foundation
import CoreLocation
import UIKit
import MapKit


class AnnotationModal: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphText: String?
    var markerTintColor: UIColor?
    var image: UIImage?
    
    init(_ coordinate: CLLocationCoordinate2D,_ title: String,_ subtitle: String,_ glyphText: String? = nil,_ markerTintColor: UIColor? = UIColor.systemBlue,_ image: UIImage? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.glyphText = glyphText
        self.markerTintColor = markerTintColor
        self.image = image
        
        super.init()
    }
    
}
