/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol ActionMenuDelegate{
    
    func startTrackRecording(at coordinate: CLLocationCoordinate2D)
    func endTrackRecording(at coordinate: CLLocationCoordinate2D?, onCompletion: @escaping () -> Void)
    
    func openCamera(at coordinate: CLLocationCoordinate2D)
    func openAudio(at coordinate: CLLocationCoordinate2D)
    func openNote(at coordinate: CLLocationCoordinate2D)
    
}

class ActionMenuView: UIView {
    
    var delegate : ActionMenuDelegate? = nil
    
    var toggleTrackingButton = UIButton().asIconButton("figure.walk")
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let insets = UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
        
        addSubviewWithAnchors(toggleTrackingButton, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: UIEdgeInsets(top: 10, left: 5, bottom: 20, right: 5))
        toggleTrackingButton.addAction(UIAction(){ action in
            self.toggleTrackRecording()
        }, for: .touchDown)
        
        let cameraButton = UIButton().asIconButton("camera")
        addSubviewWithAnchors(cameraButton, top: toggleTrackingButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: insets)
        cameraButton.addAction(UIAction(){ action in
            if let coordinate = LocationService.shared.location?.coordinate{
                self.delegate?.openCamera(at: coordinate)
            }
        }, for: .touchDown)
        
        let audioButton = UIButton().asIconButton("mic")
        addSubviewWithAnchors(audioButton, top: cameraButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: insets)
        audioButton.addAction(UIAction(){ action in
            if let coordinate = LocationService.shared.location?.coordinate{
                self.delegate?.openAudio(at: coordinate)
            }
        }, for: .touchDown)
        
        let noteButton = UIButton().asIconButton("pencil.and.list.clipboard")
        addSubviewWithAnchors(noteButton, top: audioButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 5))
        noteButton.addAction(UIAction(){ action in
            if let coordinate = LocationService.shared.location?.coordinate{
                self.delegate?.openNote(at: coordinate)
            }
        }, for: .touchDown)
    }
    
    func toggleTrackRecording(){
        if TrackRecorder.track == nil{
            if let coordinate = LocationService.shared.location?.coordinate{
                self.delegate?.startTrackRecording(at: coordinate)
                toggleTrackingButton.setImage(UIImage(systemName: "figure.walk.motion"), for: .normal)
            }
        }
        else{
            let coordinate = LocationService.shared.location?.coordinate
            self.delegate?.endTrackRecording(at: coordinate){
                if TrackRecorder.track == nil{
                    self.toggleTrackingButton.setImage(UIImage(systemName: "figure.walk"), for: .normal)
                }
            }
        }
    }
    
}






