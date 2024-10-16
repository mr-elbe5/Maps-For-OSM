//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct PreferencesView: View {
    
    @Binding var locationStatus: LocationStatus
    @Binding var preferences: WatchPreferences
    
    var body: some View {
        VStack(){
            Text("Preferences").font(Font.headline)
            Spacer()
            Toggle(isOn: $preferences.autoUpdateLocation) {
                Text("Auto Update Location")
                }
            Toggle(isOn: $preferences.showDirection) {
                Text("Show Direction")
                }
            Toggle(isOn: $preferences.showHeartRate) {
                Text("Show Heartrate")
                }
            Toggle(isOn: $preferences.showTrackpoints) {
                Text("Show Trackpoints")
                }
        }
        
    }
    
}

#Preview {
    @Previewable @State var locationStatus = LocationStatus()
    @Previewable @State var preferences = WatchPreferences()
    PreferencesView(locationStatus: $locationStatus, preferences: $preferences)
}
