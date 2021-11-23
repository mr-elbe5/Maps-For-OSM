//
//  OSM-Maps
//
//  Created by Michael Rönnau on 30.10.21.
//

import UIKit

protocol PlaceLayerViewDelegate{
    func showPlaceDetails(place: PlaceData)
    func editPlace(place: PlaceData)
    func deletePlace(place: PlaceData)
}

class PlaceLayerView: UIView {
    
    var delegate : PlaceLayerViewDelegate? = nil
    
    func setupPlaceMarkers(){
        for subview in subviews {
            subview.removeFromSuperview()
        }
        let places = PlaceController.instance.placesInPlanetRect(MapController.planetRect)
        for place in places{
            addPlaceView(place: place)
        }
    }
    
    func addPlaceView(place: PlaceData){
        let placeView = PlaceView(place: place)
        addSubview(placeView)
        placeView.delegate = self
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            $0 is PlaceView && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        let normalizedOffset = NormalizedPlanetPoint(pnt: CGPoint(x: offset.x/scale, y: offset.y/scale))
        for sv in subviews{
            if let av = sv as? PlaceView{
                av.updatePosition(to: CGPoint(x: (av.place.location.planetPosition.x - normalizedOffset.point.x)*scale , y: (av.place.location.planetPosition.y - normalizedOffset.point.y)*scale))
            }
        }
    }
    
}

extension PlaceLayerView: PlaceDelegate{
    
    func detailAction(sender: PlaceView) {
        delegate?.showPlaceDetails(place: sender.place)
    }
    
    func editAction(sender: PlaceView) {
        delegate?.editPlace(place: sender.place)
    }
    
    func deleteAction(sender: PlaceView) {
        subviews.first(where: {$0 == sender})?.removeFromSuperview()
        delegate?.deletePlace(place: sender.place)
    }
    
    
}
