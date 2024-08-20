/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import E5Data



class CrossLocationMenu: PopoverViewController {
    
    init(mapView: MapView){
        super.init()
        contentView = CrossLocationStackView(mapView: mapView, controller: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class CrossLocationStackView: NSStackView{
        
        var mapView: MapView
        var controller: PopoverViewController
        
        init(mapView: MapView, controller: PopoverViewController) {
            self.mapView = mapView
            self.controller = controller
            super.init(frame: .zero)
            orientation = .vertical
            alignment = .left
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func setupView(){
            controller.view.superview?.backgroundColor = .black
            let coordinate = mapView.scrollView.screenCenterCoordinate
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLPlacemark.getPlacemark(for: location){ placemark in
                var str : String
                if let locationmark = placemark{
                    str = locationmark.locationString.replacingOccurrences(of: "\n", with: " ")
                } else{
                    str = location.coordinate.asString
                }
                if !str.isEmpty{
                    self.addText(str)
                }
                self.addText(coordinate.shortString)
                self.addButton(title: "addImage".localize(), icon: "photo", target:self, action: #selector(self.addImageAtCross))
                self.addButton(title: "addVideo".localize(), icon: "video", target:self, action: #selector(self.addVideoAtCross))
                self.addButton(title: "addAudio".localize(), icon: "mic", target:self, action: #selector(self.addAudioAtCross))
                self.addButton(title: "addNote".localize(), icon: "pencil.and.list.clipboard", target:self, action: #selector(self.addNoteAtCross))
                let buttonView = NSStackView()
                buttonView.orientation = .horizontal
                self.addArrangedSubview(buttonView)
            }
        }
        
        @objc func addImageAtCross(){
            mapView.addImageAtCross()
        }
        
        @objc func addVideoAtCross(){
            mapView.addVideoAtCross()
        }
        
        @objc func addAudioAtCross(){
            controller.close()
            mapView.addAudioAtCross()
        }
        
        @objc func addNoteAtCross(){
            controller.close()
            mapView.addNoteAtCross()
        }
        
    }
    
}
