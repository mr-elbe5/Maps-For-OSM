//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var location: LocationManager
    
    init(){
        location = LocationManager.shared
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("Location: \(location.location.coordinate.asShortString)")
        }
        .padding()
    }
    
}

#Preview {
    ContentView()
}
