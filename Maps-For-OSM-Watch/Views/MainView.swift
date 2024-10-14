import SwiftUI

struct MainView: View {
    
    @Binding var appStatus: AppStatus
    @Binding var mapStatus: MapStatus
    @Binding var directionStatus: DirectionStatus
    @Binding var trackStatus: TrackStatus
    @Binding var healthStatus: HealthStatus
    
    var body: some View {
        GeometryReader{ proxy in
            if saveFrame(proxy.frame(in: .global)){
                ZStack(){
                    MapView(appStatus: $appStatus, mapStatus: $mapStatus)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .offset(x: mapStatus.mapOffsetX, y: mapStatus.mapOffsetY)
                        .background(.primary)
                        .clipped()
                    
                    CurrentLocationView(directionStatus: $directionStatus)
                    
                    Button("", systemImage: "plus", action: {
                        zoomIn()
                    })
                    .labelStyle(.iconOnly)
                    .background(.white)
                    .foregroundStyle(.black)
                    .frame(width: 20, height: 20)
                    .clipShape(.circle)
                    .position(x: proxy.size.width - 20, y: 20)
                    
                    Button("", systemImage: "minus", action: {
                        zoomOut()
                    })
                    .labelStyle(.iconOnly)
                    .background(.white)
                    .foregroundStyle(.black)
                    .frame(width: 20, height: 30)
                    .clipShape(.circle)
                    .position(x: proxy.size.width - 20, y: 60)
                    
                    Button("", systemImage: "stop", action: {
                        stop()
                    })
                    .labelStyle(.iconOnly)
                    .background(.white)
                    .foregroundStyle(.red)
                    .frame(width: 20, height: 30)
                    .clipShape(.circle)
                    .position(x: proxy.size.width - 20, y: proxy.size.height - 20)
                    
                    HStack{
                        Image(systemName: "triangle.bottomhalf.filled")
                        Text("\(Int(mapStatus.location.altitude)) m")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.black)
                    .offset(y: proxy.size.height/2 - 30)
                    HStack{
                        Text("❤️ \(Int(healthStatus.heartRate)) BPM")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.black)
                    .offset(y: proxy.size.height/2 - 10)
                }.frame(maxWidth: .infinity)
            }
        }
    }
    
    func zoomIn(){
        if mapStatus.zoom < World.maxZoom{
            mapStatus.zoom += 1
            mapStatus.update()
        }
    }
    
    func zoomOut(){
        if mapStatus.zoom > 10{
            mapStatus.zoom -= 1
            mapStatus.update()
        }
    }
    
    func stop(){
        
    }
    
    func saveFrame(_ rect: CGRect) -> Bool{
        AppStatus.instance.mainViewFrame = rect
        return true
    }
}

#Preview {
    @Previewable @State var appStatus = AppStatus()
    @Previewable @State var mapStatus = MapStatus()
    @Previewable @State var directionStatus = DirectionStatus()
    @Previewable @State var trackStatus = TrackStatus()
    @Previewable @State var healthStatus = HealthStatus()
    MainView(appStatus: $appStatus, mapStatus: $mapStatus, directionStatus: $directionStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
}
