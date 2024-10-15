//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct TrackView: View {
    
    @Binding var locationStatus: LocationStatus
    @Binding var trackStatus: TrackStatus
    
    var body: some View {
        VStack(){
            Text("Tracking").font(Font.headline)
            Spacer()
            if !trackStatus.isTracking{
                Button("Start", action: {
                    trackStatus.startTracking(at: locationStatus.location)
                })
                Spacer()
            }
            else{
                if trackStatus.isRecording{
                    HStack{
                        Button("Stop", action: {
                            trackStatus.stopRecording()
                        })
                    }
                    
                }
                else {
                    VStack{
                        HStack{
                            Button("Resume", action: {
                                trackStatus.resumeRecording()
                            })
                        }
                        HStack{
                            Button("Save", action: {
                                trackStatus.saveTrack()
                            })
                            .tint(.green)
                            Button("Cancel", action: {
                                trackStatus.cancelTrack()
                            })
                            .tint(.red)
                        }
                    }
                    
                }
                Spacer()
                HStack{
                    Text("Duration: \(trackStatus.durationString)")
                }
                HStack{
                    Text("Distance: \(Int(trackStatus.distance)) m")
                }
            }
        }
        
    }
    
}

#Preview {
    @Previewable @State var locationStatus = LocationStatus()
    @Previewable @State var trackStatus = TrackStatus()
    TrackView(locationStatus: $locationStatus, trackStatus: $trackStatus)
}
