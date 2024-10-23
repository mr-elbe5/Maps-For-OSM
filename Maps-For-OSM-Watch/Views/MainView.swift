import SwiftUI

struct MainView: View {
    
    @State var locationStatus = LocationStatus.shared
    @State var trackStatus = TrackStatus.shared
    @State var healthStatus = HealthStatus.shared
    @State var preferences = Preferences.shared
    
    var body: some View {
        GeometryReader{ proxy in
            if saveFrame(proxy.frame(in: .global)){
                ZStack(){
                    MapView()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .offset(x: locationStatus.mapOffsetX, y: locationStatus.mapOffsetY)
                        .background(.secondary)
                        .clipped()
                    
                    CurrentLocationView()
                    
                    Button("", systemImage: "plus", action: {
                        zoomIn()
                    })
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.black)
                    .frame(width: 20, height: 20)
                    .clipShape(.circle)
                    .position(x: proxy.size.width - 20, y: 20)
                    
                    Button("", systemImage: "minus", action: {
                        zoomOut()
                    })
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.black)
                    .frame(width: 20, height: 20)
                    .clipShape(.circle)
                    .position(x: proxy.size.width - 20, y: 50)
                    
                    Button("", systemImage: "arrow.clockwise", action: {
                        refresh()
                    })
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.black)
                    .frame(width: 20, height: 20)
                    .clipShape(.circle)
                    .position(x: proxy.size.width - 20, y: 80)
                    
                    if healthStatus.isMonitoring{
                        HStack{
                            Text("❤️ \(Int(healthStatus.heartRate))")
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
                        .position(x: proxy.size.width - 20, y: proxy.size.height - 20)
                    
                }.frame(maxWidth: .infinity)
            }
        }
    }
    
    func zoomIn(){
        if locationStatus.zoom < World.maxZoom{
            Preferences.shared.zoom += 1
            locationStatus.update()
            Preferences.shared.save()
        }
    }
    
    func zoomOut(){
        if locationStatus.zoom > 10{
            Preferences.shared.zoom -= 1
            locationStatus.update()
            Preferences.shared.save()
        }
    }
    
    func refresh(){
        LocationManager.shared.assertLocation(){ location in
            locationStatus.location = location
            locationStatus.update()
        }
    }
    
    func saveFrame(_ rect: CGRect) -> Bool{
        AppStatus.shared.mainViewFrame = rect
        return true
    }
}

#Preview {
    MainView()
}
