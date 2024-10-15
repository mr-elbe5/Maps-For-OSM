import SwiftUI

struct MainView: View {
    
    @Binding var locationStatus: LocationStatus
    @Binding var directionStatus: DirectionStatus
    @Binding var trackStatus: TrackStatus
    @Binding var healthStatus: HealthStatus
    
    var body: some View {
        GeometryReader{ proxy in
            if saveFrame(proxy.frame(in: .global)){
                ZStack(){
                    MapView(locationStatus: $locationStatus)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .offset(x: locationStatus.mapOffsetX, y: locationStatus.mapOffsetY)
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
                    .position(x: proxy.size.width - 20, y: 50)
                    
                    HStack{
                        Text("❤️ \(Int(healthStatus.heartRate)) BPM")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.black)
                    .offset(y: -proxy.size.height/2 + 20)
                    HStack{
                        Image(systemName: "triangle.bottomhalf.filled")
                        Text("\(Int(locationStatus.location.altitude)) m")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.black)
                    .offset(y: proxy.size.height/2 - 20)
                    if trackStatus.isTracking{
                        Image(systemName: trackStatus.isRecording ? "figure.walk" : "figure.stand")
                        .foregroundColor(.black)
                        .offset(x: proxy.size.width/2 - 20, y: proxy.size.height/2 - 20)
                    }
                    
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
    
    func saveFrame(_ rect: CGRect) -> Bool{
        AppStatus.shared.mainViewFrame = rect
        return true
    }
}

#Preview {
    @Previewable @State var appStatus = AppStatus()
    @Previewable @State var mapStatus = LocationStatus()
    @Previewable @State var directionStatus = DirectionStatus()
    @Previewable @State var trackStatus = TrackStatus()
    @Previewable @State var healthStatus = HealthStatus()
    MainView(locationStatus: $mapStatus, directionStatus: $directionStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
}
