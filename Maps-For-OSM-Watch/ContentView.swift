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
        GeometryReader { geometry in
            if AppStatics.setSizes(geometry){
                TabView{
                    ZStack {
                        MapView()
                            .frame(width: AppStatics.viewSize.width, height: AppStatics.viewSize.height)
                            .clipped()
                        CurrentLocationView()
                    }
                    .clipped()
                    StatusView()
                    ControlView()
                }
            }
        }
        .onAppear(){
            location.start()
        }
    }
}
    

#Preview {
    ContentView()
}
