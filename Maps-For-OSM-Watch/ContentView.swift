//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var status: Status
    @State var phoneMessaging = PhoneConnector.instance
    @State var location: LocationManager
    
    init(){
        status = Status.instance
        location = LocationManager.instance
    }
    
    var body: some View {
        TabView{
            ZStack {
                MapView()
                    .clipped()
            }
            StatusView()
            ControlView()
        }
        .onAppear(){
            location.start()
        }
    }
    
}

#Preview {
    ContentView()
}
