//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var status: Status
    @State var phoneMessaging = PhoneConnector()
    @State var location: LocationManager
    
    init(){
        status = Status.instance
        location = LocationManager.instance
    }
    
    var body: some View {
        GeometryReader{ geometry in
            if updateStatus(geometry.size){
                TabView{
                    MainView()
                    StatusView()
                    ControlView()
                }
                .onAppear(){
                    location.start()
                }
            }
        }
    }
    
    func updateStatus(_ size: CGSize) -> Bool{
        status.screenSize = size
        return true
    }
    
}

#Preview {
    ContentView()
}
