import SwiftUI

struct MainView: View {
    
    @State var model = MapModel()
    @State var direction: CLLocationDirection = LocationManager.startDirection
    
    var body: some View {
        GeometryReader{ proxy in
            if saveFrame(proxy.frame(in: .global)){
                ZStack(){
                    MapView(model: $model)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .offset(x: model.mapOffsetX, y: model.mapOffsetY)
                        .clipped()
                    
                    CurrentLocationView(direction: $direction)
                    
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
                    
                }.frame(maxWidth: .infinity)
                    .onAppear{
                        locationChanged(LocationManager.startLocation)
                        LocationManager.instance.locationDelegate = self
                    }
            }
        }
    }
    
    func zoomIn(){
        if model.zoom < World.maxZoom{
            model.zoom += 1
            model.update(coordinate: LocationManager.instance.location.coordinate)
        }
    }
    
    func zoomOut(){
        if model.zoom > 10{
            model.zoom -= 1
            model.update(coordinate: LocationManager.instance.location.coordinate)
        }
    }
    
    func saveFrame(_ rect: CGRect) -> Bool{
        Status.instance.mainViewFrame = rect
        return true
    }
}

extension MainView : LocationManagerDelegate {
    
    func locationChanged(_ location: CLLocation) {
        //print("location changed")
        model.update(coordinate: location.coordinate)
    }
    
    func directionChanged(_ direction: CLLocationDirection) {
        //print("direction changed")
        self.direction = direction
    }
    
}

#Preview {
    MainView()
}
