//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct ContentView: View, LocationServiceDelegate {
    
    @State var location: CLLocationCoordinate2D?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("Location: \(location?.asShortString ?? "Unknown")")
        }
        .padding()
    }
    
    func locationDidChange(location: CLLocation) {
        self.location = location.coordinate
    }
    
    func directionDidChange(direction: CLLocationDirection) {
        
    }
    
}

#Preview {
    ContentView()
}
