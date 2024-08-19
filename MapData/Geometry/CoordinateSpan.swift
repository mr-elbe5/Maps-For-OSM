/*
 E5MapData
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

open class CoordinateSpan{
    
    public var latitudeDelta: CLLocationDegrees
    public var longitudeDelta: CLLocationDegrees
    
    public init(){
        latitudeDelta = 0
        longitudeDelta = 0
    }
    
    public init(latitudeDelta: CLLocationDegrees, longitudeDelta: CLLocationDegrees){
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
    
}
