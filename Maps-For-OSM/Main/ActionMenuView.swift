/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5MapData
import E5IOSUI
import Maps_For_OSM_Data

protocol ActionMenuDelegate{
    
    func addPlace(at coordinate: CLLocationCoordinate2D)
    func openCamera(at coordinate: CLLocationCoordinate2D)
    func openAddImage(at coordinate: CLLocationCoordinate2D)
    func openAddNote(at coordinate: CLLocationCoordinate2D)
    func openAudioRecorder(at coordinate: CLLocationCoordinate2D)
    
    func startTrackRecording(at coordinate: CLLocationCoordinate2D)
    func saveTrack()
    func cancelTrack()
}

class ActionMenuView: UIView {
    
    var delegate : ActionMenuDelegate? = nil
    
    var toggleTrackingButton = UIButton().asIconButton("figure.walk.departure")
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let insets = UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
        
        addSubviewWithAnchors(toggleTrackingButton, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: UIEdgeInsets(top: 10, left: 5, bottom: 20, right: 5))
        toggleTrackingButton.addAction(UIAction(){ action in
            self.toggleTrackRecording()
        }, for: .touchDown)
        toggleTrackingButton.menu = getEndTrackingMenu()
        
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
                self.delegate?.openAudioRecorder(at: coordinate)
            }
        }, for: .touchDown)
        
        let noteButton = UIButton().asIconButton("pencil.and.list.clipboard")
        addSubviewWithAnchors(noteButton, top: audioButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 5))
        noteButton.addAction(UIAction(){ action in
            if let coordinate = LocationService.shared.location?.coordinate{
                self.delegate?.openAddNote(at: coordinate)
            }
        }, for: .touchDown)
    
    }
    
    func toggleTrackRecording(){
        if TrackRecorder.track == nil{
            if let coordinate = LocationService.shared.location?.coordinate{
                self.delegate?.startTrackRecording(at: coordinate)
                toggleTrackingButton.setImage(UIImage(systemName: "figure.walk.motion")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal), for: .normal)
                toggleTrackingButton.showsMenuAsPrimaryAction = true
            }
        }
    }
    
    func getEndTrackingMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "saveTrack".localize(), image: UIImage(systemName: "figure.walk.arrival")){ action in
            self.delegate?.saveTrack()
            self.toggleTrackingButton.setImage(UIImage(systemName: "figure.walk.departure"), for: .normal)
            self.toggleTrackingButton.showsMenuAsPrimaryAction = false
        })
        actions.append(UIAction(title: "cancelTrack".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)){ action in
            self.delegate?.cancelTrack()
            self.toggleTrackingButton.setImage(UIImage(systemName: "figure.walk.departure"), for: .normal)
            self.toggleTrackingButton.showsMenuAsPrimaryAction = false
        })
        return UIMenu(title: "", children: actions)
    }
    
}






