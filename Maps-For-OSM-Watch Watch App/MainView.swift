//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        ScrollView{
            ZStack {
                MapView()
            }
        }
    }
    
}

#Preview {
    MainView()
}
