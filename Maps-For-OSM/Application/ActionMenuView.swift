/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol ActionMenuDelegate{
    
    func startTrackRecording(at coordinate: CLLocationCoordinate2D)
    func pauseTrackRecording()
    func resumeTrackRecording()
    func endTrackRecording(at coordinate: CLLocationCoordinate2D?, onCompletion: @escaping () -> Void)
    func hideTrack()
    
    func openCamera(at coordinate: CLLocationCoordinate2D)
    func openAudio(at coordinate: CLLocationCoordinate2D)
    func openNote(at coordinate: CLLocationCoordinate2D)
    
}

class ActionMenuView: UIView {
    
    var delegate : ActionMenuDelegate? = nil
    
    var startTrackingButton = UIButton().asIconButton("figure.walk")
    var toggleTrackingButton = UIButton().asIconButton("pause.circle")
    var endTrackingButton = UIButton().asIconButton("stop.circle")
    
    var hideTrackButton = UIButton().asIconButton("figure.walk")
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = defaultInset
        stackView.distribution = .equalSpacing
        addSubviewFilling(stackView, insets: defaultInsets)
        
        stackView.addArrangedSubview(startTrackingButton)
        startTrackingButton.addAction(UIAction(){ action in
            self.startTrackRecording()
        }, for: .touchDown)
        
        stackView.addArrangedSubview(toggleTrackingButton)
        toggleTrackingButton.addAction(UIAction(){ action in
            self.toggleTrackRecording()
        }, for: .touchDown)
        
        stackView.addArrangedSubview(endTrackingButton)
        endTrackingButton.addAction(UIAction(){ action in
            self.endTrackRecording()
        }, for: .touchDown)
        
        let cameraButton = UIButton().asIconButton("camera")
        stackView.addArrangedSubview(cameraButton)
        cameraButton.addAction(UIAction(){ action in
            if let coordinate = LocationService.shared.location?.coordinate{
                self.delegate?.openCamera(at: coordinate)
            }
        }, for: .touchDown)
        
        let audioButton = UIButton().asIconButton("mic")
        stackView.addArrangedSubview(audioButton)
        audioButton.addAction(UIAction(){ action in
            if let coordinate = LocationService.shared.location?.coordinate{
                self.delegate?.openAudio(at: coordinate)
            }
        }, for: .touchDown)
        
        let noteButton = UIButton().asIconButton("pencil.and.list.clipboard")
        stackView.addArrangedSubview(noteButton)
        noteButton.addAction(UIAction(){ action in
            if let coordinate = LocationService.shared.location?.coordinate{
                self.delegate?.openNote(at: coordinate)
            }
        }, for: .touchDown)
        updateButtons()
    }
    
    func updateButtons(){
        if TrackRecorder.track != nil{
            startTrackingButton.setImage(UIImage(systemName: "figure.walk.motion"), for: .normal)
            startTrackingButton.isEnabled = false
            if TrackRecorder.isRecording{
                toggleTrackingButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            }
            else{
                toggleTrackingButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            }
            toggleTrackingButton.isHidden = false
            endTrackingButton.isHidden = false
        }
        else{
            startTrackingButton.setImage(UIImage(systemName: "figure.walk"), for: .normal)
            startTrackingButton.isEnabled = true
            toggleTrackingButton.isHidden = true
            endTrackingButton.isHidden = true
        }
    }
    
    func startTrackRecording(){
        if TrackRecorder.track == nil, let coordinate = LocationService.shared.location?.coordinate{
            self.delegate?.startTrackRecording(at: coordinate)
            self.updateButtons()
        }
    }
    
    func toggleTrackRecording(){
        if TrackRecorder.track != nil{
            if TrackRecorder.isRecording{
                self.delegate?.pauseTrackRecording()
            }
            else{
                self.delegate?.resumeTrackRecording()
            }
            self.updateButtons()
        }
    }
    
    func endTrackRecording(){
        let coordinate = LocationService.shared.location?.coordinate
        self.delegate?.endTrackRecording(at: coordinate){
            self.updateButtons()
        }
    }
    
}






