//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var phoneMessaging = PhoneConnector.instance
    
    var body: some View {
        TabView(){
            MainView()
                .onAppear() {
                    PhoneConnector.instance.requestLocation( completion: { location in
                        LocationStatus.shared.location = location
                        LocationStatus.shared.update()
                    })
                }
            TrackView()
            PreferencesView()
        }
    }
}
    
#Preview {
    ContentView()
}
