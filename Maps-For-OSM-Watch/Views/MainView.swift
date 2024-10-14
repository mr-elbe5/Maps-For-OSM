import SwiftUI

struct MainView: View {
    
    @Binding var appStatus: AppStatus
    @Binding var mapStatus: MapStatus
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
                    
                    CurrentLocationView()
                    
                    Button("", systemImage: "plus", action: {
                        zoomIn()
                    })
                    .labelStyle(.iconOnly)
                    .background(.white)
                    .foregroundStyle(.black)
                    .frame(width: 30, height: 30)
                    .clipShape(.circle)
                    .position(x: proxy.size.width - 20, y: 20)
                    
                    Button("", systemImage: "minus", action: {
                        zoomOut()
                    })
                    .labelStyle(.iconOnly)
                    .background(.white)
                    .foregroundStyle(.black)
                    .frame(width: 30, height: 30)
                    .clipShape(.circle)
                    .position(x: proxy.size.width - 20, y: 60)
                    
                    Text("\(Int(mapStatus.altitude))m")
                        .foregroundColor(.black)
                        .offset(y: proxy.size.height/2 - 15)
                    
                }.frame(maxWidth: .infinity)
            }
        }
    }
    
    func zoomIn(){
        if mapStatus.zoom < World.maxZoom{
            mapStatus.zoom += 1
            mapStatus.update(coordinate: LocationManager.instance.location.coordinate)
        }
    }
    
    func zoomOut(){
        if mapStatus.zoom > 10{
            mapStatus.zoom -= 1
            mapStatus.update(coordinate: LocationManager.instance.location.coordinate)
        }
    }
    
    func saveFrame(_ rect: CGRect) -> Bool{
        AppStatus.instance.mainViewFrame = rect
        return true
    }
}

#Preview {
    @Previewable @State var appStatus = AppStatus()
    @Previewable @State var mapStatus = MapStatus()
    @Previewable @State var trackStatus = TrackStatus()
    @Previewable @State var healthStatus = HealthStatus()
    MainView(appStatus: $appStatus, mapStatus: $mapStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
}
