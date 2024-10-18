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
                .onAppear(){
                    print("main appeared")
                }
            TrackView()
                .onAppear(){
                    print("track appeared")
                }
            PreferencesView()
                .onAppear(){
                    print("prefs appeared")
                }
        }
        .onAppear(){
            print("content appeared")
        }
    }
}
    
#Preview {
    ContentView()
}
