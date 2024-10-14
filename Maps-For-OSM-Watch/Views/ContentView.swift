//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var phoneMessaging = PhoneConnector.instance
    
    @Binding var locationStatus: LocationStatus
    @Binding var directionStatus: DirectionStatus
    @Binding var trackStatus: TrackStatus
    @Binding var healthStatus: HealthStatus
    
    var body: some View {
        TabView(){
            MainView(locationStatus: $locationStatus, directionStatus: $directionStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
            TrackView(trackStatus: $trackStatus)
        }
    }
}
    
#Preview {
    @Previewable @State var locationStatus = LocationStatus()
    @Previewable @State var directionStatus = DirectionStatus()
    @Previewable @State var trackStatus = TrackStatus()
    @Previewable @State var healthStatus = HealthStatus()
    ContentView(locationStatus: $locationStatus, directionStatus: $directionStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
}
