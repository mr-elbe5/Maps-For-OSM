import SwiftUI

struct MainView: View {
    
    @State var locationStatus = LocationStatus.shared
    @State var trackStatus = TrackStatus.shared
    @State var healthStatus = HealthStatus.shared
    @State var preferences = WatchPreferences.shared
    
    var body: some View {
        GeometryReader{ proxy in
            if saveFrame(proxy.frame(in: .global)){
                ZStack(){
                    MapView()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .offset(x: locationStatus.mapOffsetX, y: locationStatus.mapOffsetY)
                        .background(.primary)
                        .clipped()
                    
                    CurrentLocationView()
                    
                    Button("", systemImage: "plus", action: {
                        zoomIn()
                    })
                    .labelStyle(.iconOnly)
                    .buttonStyle(PlainButtonStyle())
                    .foregroundStyle(.black)
                    .frame(width: 20, height: 20)
                    .position(x: proxy.size.width - 20, y: 20)
                    
                    Button("", systemImage: "minus", action: {
                        zoomOut()
                    })
                    .labelStyle(.iconOnly)
                    .buttonStyle(PlainButtonStyle())
                    .foregroundStyle(.black)
                    .frame(width: 20, height: 30)
                    .position(x: proxy.size.width - 20, y: 50)
                    
                    if !preferences.autoUpdateLocation{
                        Button("", systemImage: "arrow.clockwise", action: {
                            refresh()
                        })
                        .labelStyle(.iconOnly)
                        .buttonStyle(PlainButtonStyle())
                        .foregroundStyle(.black)
                        .frame(width: 20, height: 30)
                        .position(x: proxy.size.width - 20, y: 80)
                    }
                    
                    if preferences.showHeartRate{
                        HStack{
                            Text("❤️ \(Int(healthStatus.heartRate)) BPM")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.black)
                        .offset(y: -proxy.size.height/2 + 20)
                    }
                    if let location = locationStatus.location{
                        HStack{
                            Image(systemName: "triangle.bottomhalf.filled")
                            Text("\(Int(location.altitude)) m")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.black)
                        .offset(y: proxy.size.height/2 - 20)
                    }
                    Image(systemName: trackStatus.isRecording ? "figure.walk" : "figure.stand")
                        .foregroundColor(.black)
                        .position(x: proxy.size.width - 20, y: proxy.size.height - 30)
                    
                }.frame(maxWidth: .infinity)
            }
        }
    }
    
    func zoomIn(){
        if locationStatus.zoom < World.maxZoom{
            locationStatus.zoom += 1
            locationStatus.update()
        }
    }
    
    func zoomOut(){
        if locationStatus.zoom > 10{
            locationStatus.zoom -= 1
            locationStatus.update()
        }
    }
    
    func refresh(){
        //locationStatus.location = LocationManager.shared.location
        TrackSample.shared.nextStep()
        locationStatus.update()
    }
    
    func saveFrame(_ rect: CGRect) -> Bool{
        AppStatus.shared.mainViewFrame = rect
        return true
    }
}

#Preview {
    MainView()
}
