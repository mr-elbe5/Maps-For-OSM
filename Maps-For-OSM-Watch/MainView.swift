import SwiftUI

struct MainView: View {
    
    @State var debug = false
    @State var offsetX: CGFloat = 0
    @State var offsetY: CGFloat = 0
    @State var currentDirection: CLLocationDirection = LocationManager.startDirection
    
    var body: some View {
        GeometryReader{ proxy in
            ZStack(){
                if debug{
                    Text("\(proxy.frame(in: .global))")
                        .offset(y: -130)
                }
                MapView(offsetX: $offsetX, offsetY: $offsetY, direction: $currentDirection, size: proxy.size)
                    .frame(width: proxy.size.width, height: proxy.size.width)
                    .offset(x: -offsetX, y: -offsetY)
                    .clipped()
                CurrentLocationView(direction: $currentDirection)
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
                .background(.teal)
        }
    }
        
}

#Preview {
    MainView()
}
