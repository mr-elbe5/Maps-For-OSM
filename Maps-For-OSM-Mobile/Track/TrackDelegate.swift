//
//  LocationDelegate.swift
//  Maps-For-OSM
//
//  Created by Michael Rönnau on 21.10.24.
//


/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import CoreLocation

protocol TrackDelegate{
    
    func showTrackOnMap(track: TrackItem)
    func editTrack(track: TrackItem)
    func trackChanged()
    
    func cancelActiveTrack()
    func saveActiveTrack()
}

extension TrackDelegate{
    
    func showTrackOnMap(track: TrackItem){
    }
    
    func editTrack(track: TrackItem){
    }
    
    func trackChanged(){
    }
    
    func cancelActiveTrack(){
    }
    
    func saveActiveTrack(){
    }
    
}
