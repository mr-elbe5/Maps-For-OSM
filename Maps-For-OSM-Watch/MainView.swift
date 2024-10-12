import SwiftUI

struct MainView: View {
    
    @State var debug = false
    @State var model = MapModel()
    @State var direction: CLLocationDirection = LocationManager.startDirection
    
    var body: some View {
        GeometryReader{ proxy in
            if saveFrame(proxy.frame(in: .global)){
                ZStack(){
                    if debug{
                        Text("\(proxy.frame(in: .global))")
                            .offset(y: -130)
                    }
                    MapView(model: $model)
                        .frame(width: proxy.size.width, height: proxy.size.width)
                        .offset(x: model.mapOffsetX, y: model.mapOffsetY)
                        .clipped()
                    CurrentLocationView(direction: $direction)
                    if debug{
                        Text(" \(proxy.frame(in: .local)))")
                            .foregroundColor(.black)
                            .offset(y: 20)
                        Text("offX: \(128 - Int(proxy.size.width/2))")
                            .foregroundColor(.black)
                            .offset(y: 40)
                        Text("offY: \(128 - Int(proxy.size.height/2))")
                            .foregroundColor(.black)
                            .offset(y: 55)
                    }
                    
                    
                }.frame(maxWidth: .infinity)
                    .onAppear{
                        locationChanged(LocationManager.startLocation)
                        LocationManager.instance.locationDelegate = self
                    }
            }
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
