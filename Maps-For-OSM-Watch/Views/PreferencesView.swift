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
            Text("preferences".localize()).font(Font.headline)
            Spacer()
            Toggle(isOn: $preferences.autoUpdateLocation) {
                Text("followLocation".localize())
                }
            Toggle(isOn: $preferences.showDirection) {
                Text("showDirection".localize())
                }
            Spacer()
            Button("clearMapTiles".localize(), action: {
                    _ = FileManager.default.deleteAllFiles(dirURL: FileManager.tileDirURL)
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
