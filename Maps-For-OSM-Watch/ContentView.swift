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
    
    init(){
        location = LocationManager.instance
    }
    
    var body: some View {
        if AppStatics.setSizes(){
            TabView(){
                ZStack{
                    MapView()
                        .onAppear(){
                            location.start()
                        }
                    CurrentLocationView()
                }
                StatusView()
                ControlView()
            }
        }
    }
}
    

#Preview {
    ContentView()
}
