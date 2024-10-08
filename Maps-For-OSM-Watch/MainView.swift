//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct MainView: View {
    
    @State var status = Status.instance
    
    var body: some View {
        ZStack {
            MapView()
                .frame(width: status.screenSize.width, height: status.screenSize.height)
                .clipped()
        }
    }
    
}

#Preview {
    MainView()
}
