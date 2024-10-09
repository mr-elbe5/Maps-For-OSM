//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct StatusView: View {
    
    @State var status: Status = Status.instance
    @State var locationManager: LocationManager = LocationManager.instance
    
    var body: some View {
        VStack {
            Text("screenSize = \(AppStatics.screenSize)")
            Text("Location: \(locationManager.location.coordinate.asShortString)")
        }
    }
    
}

#Preview {
    StatusView()
}
