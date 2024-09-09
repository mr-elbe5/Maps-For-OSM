/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5IOSUI

protocol TrackStatusDelegate{
    func togglePauseTracking()
}

class StatusView : UIView{
    
    var defaultView = UIView()
    
    var compassLabel = UILabel(text: "0°").withTextColor(.darkText)
    var heightLabel = UILabel(text: "0 m").withTextColor(.darkText)
    var coordinateLabel = UILabel(text: "").withTextColor(.darkText)
    
    var trackStatusView = UIView()
    
    var pauseResumeButton = UIButton()
    var distanceLabel = UILabel(text: "0 m")
    var distanceUpLabel = UILabel(text: "0 m")
    var distanceDownLabel = UILabel(text: "0 m")
    var timeLabel = UILabel()
    
    var timer : Timer? = nil
    
    var zeroHeightConstraint: NSLayoutConstraint? = nil
    
    var delegate: TrackStatusDelegate? = nil
    
    func setup(){
        layer.cornerRadius = 10
        layer.masksToBounds = true
        zeroHeightConstraint = heightAnchor.constraint(equalToConstant: 0)
        
        addSubviewWithAnchors(defaultView, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        
        let compassIcon = UIImageView(image: UIImage(systemName: "safari"))
        compassIcon.tintColor = .darkText
        defaultView.addSubviewWithAnchors(compassIcon, top: defaultView.topAnchor, leading: defaultView.leadingAnchor, bottom: defaultView.bottomAnchor, insets: smallInsets)
        compassLabel = UILabel(text: "0°").withTextColor(.darkText)
        defaultView.addSubviewWithAnchors(compassLabel, top: defaultView.topAnchor, leading: compassIcon.trailingAnchor, bottom: defaultView.bottomAnchor, insets: smallInsets)
        let heightIcon = UIImageView(image: UIImage(systemName: "mountain.2.circle"))
        heightIcon.tintColor = .darkText
        defaultView.addSubviewWithAnchors(heightIcon, top: defaultView.topAnchor, leading: compassLabel.trailingAnchor, bottom: defaultView.bottomAnchor, insets: smallInsets)
        defaultView.addSubviewWithAnchors(heightLabel, top: defaultView.topAnchor, leading: heightIcon.trailingAnchor, bottom: defaultView.bottomAnchor, insets: smallInsets)
        defaultView.addSubviewWithAnchors(coordinateLabel, top: defaultView.topAnchor, trailing: defaultView.trailingAnchor, bottom: defaultView.bottomAnchor, insets: smallInsets)
        
        addSubviewWithAnchors(trackStatusView, top: defaultView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        
        let distanceIcon = UIImageView(image: UIImage(systemName: "arrow.right"))
        distanceIcon.tintColor = .darkText
        trackStatusView.addSubviewWithAnchors(distanceIcon, top: trackStatusView.topAnchor, leading: trackStatusView.leadingAnchor, bottom: trackStatusView.bottomAnchor, insets: smallInsets)
        distanceLabel.textColor = .darkText
        trackStatusView.addSubviewWithAnchors(distanceLabel, top: trackStatusView.topAnchor, leading: distanceIcon.trailingAnchor, bottom: trackStatusView.bottomAnchor, insets: smallInsets)
        
        let distanceUpIcon = UIImageView(image: UIImage(systemName: "arrow.up"))
        distanceUpIcon.tintColor = .darkText
        trackStatusView.addSubviewWithAnchors(distanceUpIcon, top: trackStatusView.topAnchor, leading: distanceLabel.trailingAnchor, bottom: trackStatusView.bottomAnchor, insets: smallInsets)
        distanceUpLabel.textColor = .darkText
        trackStatusView.addSubviewWithAnchors(distanceUpLabel, top: trackStatusView.topAnchor, leading: distanceUpIcon.trailingAnchor, bottom: trackStatusView.bottomAnchor, insets: smallInsets)
        
        let distanceDownIcon = UIImageView(image: UIImage(systemName: "arrow.down"))
        distanceDownIcon.tintColor = .darkText
        trackStatusView.addSubviewWithAnchors(distanceDownIcon, top: trackStatusView.topAnchor, leading: distanceUpLabel.trailingAnchor, bottom: trackStatusView.bottomAnchor, insets: smallInsets)
        distanceDownLabel.textColor = .darkText
        trackStatusView.addSubviewWithAnchors(distanceDownLabel, top: trackStatusView.topAnchor, leading: distanceDownIcon.trailingAnchor, bottom: trackStatusView.bottomAnchor, insets: smallInsets)
        
        let timeIcon = UIImageView(image: UIImage(systemName: "stopwatch"))
        timeIcon.tintColor = .darkText
        trackStatusView.addSubviewWithAnchors(timeIcon, top: trackStatusView.topAnchor, leading: distanceDownLabel.trailingAnchor, bottom: trackStatusView.bottomAnchor, insets: smallInsets)
        timeLabel.textColor = .darkText
        trackStatusView.addSubviewWithAnchors(timeLabel, top: trackStatusView.topAnchor, leading: timeIcon.trailingAnchor, bottom: trackStatusView.bottomAnchor, insets: smallInsets)
        
        pauseResumeButton.asIconButton("pause.circle")
        pauseResumeButton.tintColor = .darkText
        pauseResumeButton.addAction(UIAction(){ action in
            self.togglePauseResume()
        }, for: .touchDown)
        trackStatusView.addSubviewWithAnchors(pauseResumeButton, top: trackStatusView.topAnchor, trailing: trackStatusView.trailingAnchor, bottom: trackStatusView.bottomAnchor, insets: smallInsets)
        
        zeroHeightConstraint = trackStatusView.heightAnchor.constraint(equalToConstant: 0)
        zeroHeightConstraint?.isActive = true
    }
    
    
    func updateLocationInfo(location: CLLocation){
        heightLabel.text = "\(Int(location.altitude)) m"
        coordinateLabel.text = location.coordinate.asShortString
    }
    
    func updateDirection(direction: CLLocationDirection) {
        compassLabel.text="\(Int(direction))°"
    }
    
    func startTrackInfo(){
        trackStatusView.isHidden = false
        zeroHeightConstraint?.isActive = false
        pauseResumeButton.asIconButton("pause.circle", color: .darkText)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTrackInfo(){
        if let track = TrackRecorder.instance?.track{
            distanceLabel.text = "\(Int(track.distance)) m"
            distanceUpLabel.text = "\(Int(track.upDistance)) m"
            distanceDownLabel.text = "\(Int(track.downDistance)) m"
            heightLabel.text = "\(Int(track.lastAltitude)) m"
        }
    }
    
    func pauseTrackInfo(){
        timer?.invalidate()
        timer = nil
    }
    
    func resumeTrackInfo(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func stopTrackInfo(){
        timer?.invalidate()
        timer = nil
        trackStatusView.isHidden = true
        zeroHeightConstraint?.isActive = true
    }
    
    @objc func updateTime(){
        if let track = TrackRecorder.instance?.track{
            timeLabel.text = track.durationUntilNow.hmString()
        }
    }
    
    func togglePauseResume(){
        delegate?.togglePauseTracking()
        pauseResumeButton.asIconButton(TrackRecorder.isRecording ? "pause.circle" : "play.circle", color: .darkText)
    }
    
}
