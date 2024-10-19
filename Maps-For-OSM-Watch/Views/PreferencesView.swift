//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct PreferencesView: View {
    
    @State var locationStatus = LocationStatus.shared
    @State var preferences = Preferences.shared
    
    var body: some View {
        VStack(){
            Text("Preferences").font(Font.headline)
            Spacer()
            Toggle(isOn: $preferences.autoUpdateLocation) {
                Text("Follow Location")
                }
            Toggle(isOn: $preferences.showDirection) {
                Text("Show Direction")
                }
            Spacer()
            Button("Clear Map Tiles", action: {
                    _ = FileManager.default.deleteAllFiles(dirURL: FileManager.tilesDirURL)
                })
                .buttonStyle(PlainButtonStyle())
                .foregroundStyle(.red)
        }
        .onChange(of: preferences.showDirection){
            LocationManager.shared.updateFollowDirection()
            Preferences.shared.save()
        }
        .onChange(of: preferences.autoUpdateLocation){
            Preferences.shared.save()
        }
    }
    
}

#Preview {
    PreferencesView()
}
