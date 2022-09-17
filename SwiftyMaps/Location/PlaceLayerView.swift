/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol PlaceLayerViewDelegate{
    func showLocationDetails(location: Place)
}

class PlaceLayerView: UIView {
    
    //MainViewController
    var delegate : PlaceLayerViewDelegate? = nil
    
    func setupPins(zoom: Int, offset: CGPoint, scale: CGFloat){
        for subview in subviews {
            subview.removeFromSuperview()
        }
        if zoom == MapStatics.maxZoom{
            for location in Places.list{
                let pin = PlacePin(location: location)
                addSubview(pin)
                pin.addTarget(self, action: #selector(showLocationDetails), for: .touchDown)
            }
        }
        else{
            let planetDist = MapStatics.zoomScaleToPlanet(from: zoom) * 10 // 10m at full zoom
            var groups = Array<PlaceGroup>()
            for location in Places.list{
                var grouped = false
                for group in groups{
                    if group.isWithinRadius(location: location, radius: planetDist){
                        group.addLocation(location: location)
                        group.setCenter()
                        grouped = true
                    }
                }
                if !grouped{
                    let group = PlaceGroup()
                    group.addLocation(location: location)
                    group.setCenter()
                    groups.append(group)
                }
            }
            for group in groups{
                if group.locations.count > 1{
                    let pin = PlaceGroupPin(locationGroup: group)
                    addSubview(pin)
                }
                else if let location = group.locations.first{
                    let pin = PlacePin(location: location)
                    addSubview(pin)
                    pin.addTarget(self, action: #selector(showLocationDetails), for: .touchDown)
                }
            }
            
        }
        updatePosition(offset: offset, scale: scale)
    }
    
    func getPin(location: Place) -> Pin?{
        for subview in subviews{
            if let pin = subview as? PlacePin, pin.location == location{
                return pin
            }
            if let pin = subview as? PlaceGroupPin, pin.locationGroup.hasLocation(location: location){
                return pin
            }
        }
        return nil
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            $0 is Pin && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        let normalizedOffset = NormalizedPlanetPoint(pnt: CGPoint(x: offset.x/scale, y: offset.y/scale))
        for sv in subviews{
            if let av = sv as? PlacePin{
                av.updatePosition(to: CGPoint(x: (av.location.planetPosition.x - normalizedOffset.point.x)*scale , y: (av.location.planetPosition.y - normalizedOffset.point.y)*scale))
            }
            else if let av = sv as? PlaceGroupPin, let center = av.locationGroup.centerPlanetPosition{
                av.updatePosition(to: CGPoint(x: (center.x - normalizedOffset.point.x)*scale , y: (center.y - normalizedOffset.point.y)*scale))
            }
        }
    }
    
    func updateLocationState(_ location: Place){
        if let pin = getPin(location: location){
            pin.updateImage()
        }
    }
    
    @objc func showLocationDetails(_ sender: AnyObject){
        if let pin = sender as? PlacePin{
            delegate?.showLocationDetails(location: pin.location)
        }
    }
    
}



