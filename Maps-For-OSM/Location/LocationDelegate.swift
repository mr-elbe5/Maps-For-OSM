/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

protocol LocationDelegate{
    
    func addPlace(at coordinate: CLLocationCoordinate2D)
    func openCamera(at coordinate: CLLocationCoordinate2D)
    func openAddImage(at coordinate: CLLocationCoordinate2D)
    func openAddNote(at coordinate: CLLocationCoordinate2D)
    func openAudioRecorder(at coordinate: CLLocationCoordinate2D)
    
    func startTrackRecording(at coordinate: CLLocationCoordinate2D)
    func endTrackRecording(at coordinate: CLLocationCoordinate2D?, onCompletion: @escaping () -> Void)
}
