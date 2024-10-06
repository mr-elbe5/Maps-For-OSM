//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var phoneMessaging = PhoneMessaging()
    @State var location: LocationManager
    
    init(){
        location = LocationManager.shared
    }
    
    var body: some View {
        ScrollView{
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                Text("Location: \(location.location.coordinate.asShortString)")
                Button("Request Info") {
                    phoneMessaging.requestInfo()
                }
                ForEach(phoneMessaging.messages, id: \.self) { message in
                    Text(message)
                }
            }
        }
    }
    
}

#Preview {
    ContentView()
}
