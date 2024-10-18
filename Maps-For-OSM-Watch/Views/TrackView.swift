//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct TrackView: View {
    
    @State var locationStatus = LocationStatus.shared
    @State var trackStatus = TrackStatus.shared
    @State var preferences = WatchPreferences.shared
    
    var body: some View {
            VStack(){
                Text("Tracking").font(Font.headline)
                Spacer()
                if !trackStatus.isTracking{
                    Button("Start", action: {
                        trackStatus.startTracking()
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
                                    trackStatus.stopTracking()
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
                    if preferences.showTrackpoints{
                        HStack{
                            Text("Trackpoints: \(trackStatus.trackpointCount)")
                        }
                    }
                }
    
                
        }
        
        
    }
    
}

#Preview {
    TrackView()
}
