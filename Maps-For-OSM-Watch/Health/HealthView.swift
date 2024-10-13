//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI
import HealthKit

struct HealthView: View {
    
    @State var monitor = HeartRateMonitor()
    
    var body: some View {
        ScrollView{
            VStack {
                HStack{
                    Text("❤️")
                        .font(.system(size: 20))
                    Text("\(Int(monitor.heartRate))")
                        .fontWeight(.regular)
                        .font(.system(size: 20))
                    Text("BPM")
                        .fontWeight(.regular)
                        .font(.system(size: 20))
                        .foregroundColor(Color.red)
                    Spacer()
                }
                .padding()
                .onAppear(){
                    monitor.startMonitoring()
                }
            }
        }
    }
    
}

#Preview {
    HealthView()
}
