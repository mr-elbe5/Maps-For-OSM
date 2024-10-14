//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var phoneMessaging = PhoneConnector.instance
    
    @Binding var appStatus: AppStatus
    @Binding var mapStatus: MapStatus
    @Binding var directionStatus: DirectionStatus
    @Binding var trackStatus: TrackStatus
    @Binding var healthStatus: HealthStatus
    
    var body: some View {
        TabView(){
            MainView(appStatus: $appStatus, mapStatus: $mapStatus, directionStatus: $directionStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
            TrackView(appStatus: $appStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
        }
    }
}
    
#Preview {
    @Previewable @State var appStatus = AppStatus()
    @Previewable @State var mapStatus = MapStatus()
    @Previewable @State var directionStatus = DirectionStatus()
    @Previewable @State var trackStatus = TrackStatus()
    @Previewable @State var healthStatus = HealthStatus()
    ContentView(appStatus: $appStatus, mapStatus: $mapStatus, directionStatus: $directionStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
}
