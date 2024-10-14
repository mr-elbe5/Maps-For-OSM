//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var phoneMessaging = PhoneConnector.instance
    @State var location: LocationManager
    
    @State var appStatus = AppStatus()
    @State var mapStatus = MapStatus()
    @State var trackStatus = TrackStatus()
    @State var healthStatus = HealthStatus()
    
    init(){
        location = LocationManager.instance
    }
    
    var body: some View {
        TabView(){
            MainView(appStatus: $appStatus, mapStatus: $mapStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
            TrackView(appStatus: $appStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
        }
        .onAppear(){
            LocationManager.instance.start()
            locationChanged(LocationManager.startLocation)
            LocationManager.instance.locationDelegate = self
        }
    }
}
    
extension ContentView : LocationDelegate {
    
    func locationChanged(_ location: CLLocation) {
        //print("location changed")
        mapStatus.update(coordinate: location.coordinate)
    }
    
}

#Preview {
    ContentView()
}
