/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5MapData

extension MainViewController: NoteViewDelegate{
    
    func openAddNote(at coordinate: CLLocationCoordinate2D) {
        let controller = NoteViewController(coordinate: coordinate)
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func addNote(text: String, coordinate: CLLocationCoordinate2D) {
        if !text.isEmpty{
            var newLocation = false
            var location = AppData.shared.getLocation(coordinate: coordinate)
            if location == nil{
                location = AppData.shared.createLocation(coordinate: coordinate)
                newLocation = true
            }
            let note = Note()
            note.text = text
            location!.addItem(item: note)
            AppData.shared.save()
            DispatchQueue.main.async {
                if newLocation{
                    self.locationAdded(location: location!)
                }
                else{
                    self.locationChanged(location: location!)
                }
                self.showLocationOnMap(coordinate: location!.coordinate)
            }
        }
    }
    
}


