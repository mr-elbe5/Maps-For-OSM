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
    @Binding var preferences: WatchPreferences
    
    var body: some View {
        TabView(){
            MainView(locationStatus: $locationStatus, directionStatus: $directionStatus, trackStatus: $trackStatus, healthStatus: $healthStatus, preferences: $preferences)
            TrackView(locationStatus: $locationStatus, trackStatus: $trackStatus, preferences: $preferences)
            PreferencesView(locationStatus: $locationStatus, preferences: $preferences)
        }
    }
}
    
#Preview {
    @Previewable @State var locationStatus = LocationStatus()
    @Previewable @State var directionStatus = DirectionStatus()
    @Previewable @State var trackStatus = TrackStatus()
    @Previewable @State var healthStatus = HealthStatus()
    @Previewable @State var preferences = WatchPreferences()
    ContentView(locationStatus: $locationStatus, directionStatus: $directionStatus, trackStatus: $trackStatus, healthStatus: $healthStatus, preferences: $preferences)
}
