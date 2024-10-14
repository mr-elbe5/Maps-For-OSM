//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct TrackView: View {
    
    @Binding var trackStatus: TrackStatus
    
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
        }
        
    }
    
}

#Preview {
    @Previewable @State var trackStatus = TrackStatus()
    TrackView(trackStatus: $trackStatus)
}
