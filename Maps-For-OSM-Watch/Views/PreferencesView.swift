//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct PreferencesView: View {
    
    @Binding var locationStatus: LocationStatus
    
    var body: some View {
        VStack(){
            Text("Preferences").font(Font.headline)
            Spacer()
            
        }
        
    }
    
}

#Preview {
    @Previewable @State var locationStatus = LocationStatus()
    PreferencesView(locationStatus: $locationStatus)
}
