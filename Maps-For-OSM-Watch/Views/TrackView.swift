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
    @State var preferences = Preferences.shared
    
    var body: some View {
            VStack(){
                Text("recordTrack".localize()).font(Font.headline)
                Spacer()
                if !trackStatus.isTracking{
                    Button("start".localize(), action: {
                        trackStatus.startTracking()
                    })
                    Spacer()
                }
                else{
                    if trackStatus.isRecording{
                        HStack{
                            Button("stop".localize(), action: {
                                trackStatus.stopRecording()
                            })
                        }
                        
                    }
                    else {
                        VStack{
                            HStack{
                                Button("resume".localize(), action: {
                                    trackStatus.resumeRecording()
                                })
                            }
                            HStack{
                                Button("save".localize(), action: {
                                    trackStatus.saveTrack()
                                })
                                .tint(.green)
                                Button("delete".localize(), action: {
                                    trackStatus.stopTracking()
                                })
                                .tint(.red)
                            }
                        }
                        
                    }
                    Spacer()
                    HStack{
                        Text("\("duration".localize()): \(trackStatus.durationString)")
                    }
                    HStack{
                        Text("\("distance".localize()): \(Int(trackStatus.distance)) m")
                    }
                    HStack{
                        Text("\("trackpoints".localize()): \(trackStatus.trackpointCount)")
                    }
                }
    
                
        }
        
        
    }
    
}

#Preview {
    TrackView()
}
