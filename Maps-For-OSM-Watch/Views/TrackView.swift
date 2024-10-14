//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct TrackView: View {
    
    @Binding var appStatus: AppStatus
    @Binding var trackStatus: TrackStatus
    @Binding var healthStatus: HealthStatus
    
    var body: some View {
        VStack(){
            Text("Tracking").font(Font.headline)
            Spacer()
            if !trackStatus.isRecording{
                HStack{
                    if trackStatus.distance == 0{
                        Button("Start", action: {
                            trackStatus.isRecording = true
                            trackStatus.distance = 345
                        })
                    }
                    else{
                        Button("Resume", action: {
                            trackStatus.isRecording = true
                            trackStatus.distance += 100
                        })
                    }
                }
            }
            else {
                HStack{
                    Button("Pause", action: {
                        trackStatus.isRecording = false
                    })
                    Button("Save", action: {
                        trackStatus.isRecording = false
                        trackStatus.distance = 0
                    })
                    .tint(.green)
                    Button("Stop", action: {
                        trackStatus.isRecording = false
                        trackStatus.distance = 0
                    })
                    .tint(.red)
                }
                Spacer()
                HStack{
                    Text("From \(trackStatus.startTime.timeString()) to \(trackStatus.endTime.timeString())")
                }
                HStack{
                    Text("Distance: \(Int(trackStatus.distance)) m")
                }
            }
            Spacer()
            HStack{
                Text("❤️")
                    .font(.system(size: 20))
                Text("\(Int(67))")
                    .fontWeight(.regular)
                    .font(.system(size: 20))
                Text("BPM")
                    .fontWeight(.regular)
                    .font(.system(size: 20))
                    .foregroundColor(Color.red)
            }
        }
        
    }
    
}

#Preview {
    @Previewable @State var appStatus = AppStatus()
    @Previewable @State var trackStatus = TrackStatus()
    @Previewable @State var healthStatus = HealthStatus()
    TrackView(appStatus: $appStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
}
