/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

protocol TrackStatusDelegate{
    func togglePauseTracking()
}

class TrackStatusView : UIView{
    
    
    var pauseResumeButton = UIButton()
    
    var distanceLabel = UILabel(text: "0 m")
    var distanceUpLabel = UILabel(text: "0 m")
    var distanceDownLabel = UILabel(text: "0 m")
    var speedLabel = UILabel(text: "0 km/h")
    var timeLabel = UILabel()
    
    var timer : Timer? = nil
    
    var delegate: TrackStatusDelegate? = nil
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        let distanceIcon = UIImageView(image: UIImage(systemName: "arrow.right"))
        distanceIcon.tintColor = .darkGray
        addSubviewWithAnchors(distanceIcon, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: smallInsets)
        distanceLabel.textColor = .darkGray
        addSubviewWithAnchors(distanceLabel, top: topAnchor, leading: distanceIcon.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        
        let distanceUpIcon = UIImageView(image: UIImage(systemName: "arrow.up"))
        distanceUpIcon.tintColor = .darkGray
        addSubviewWithAnchors(distanceUpIcon, top: topAnchor, leading: distanceLabel.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        distanceUpLabel.textColor = .darkGray
        addSubviewWithAnchors(distanceUpLabel, top: topAnchor, leading: distanceUpIcon.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        
        let distanceDownIcon = UIImageView(image: UIImage(systemName: "arrow.down"))
        distanceDownIcon.tintColor = .darkGray
        addSubviewWithAnchors(distanceDownIcon, top: topAnchor, leading: distanceUpLabel.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        distanceDownLabel.textColor = .darkGray
        addSubviewWithAnchors(distanceDownLabel, top: topAnchor, leading: distanceDownIcon.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        
        let speedIcon = UIImageView(image: UIImage(systemName: "speedometer"))
        speedIcon.tintColor = .darkGray
        addSubviewWithAnchors(speedIcon, top: topAnchor, leading: distanceDownLabel.trailingAnchor, bottom: bottomAnchor, insets: flatInsets)
        speedLabel.textColor = .darkGray
        addSubviewWithAnchors(speedLabel, top: topAnchor, leading: speedIcon.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        
        let timeIcon = UIImageView(image: UIImage(systemName: "stopwatch"))
        timeIcon.tintColor = .darkGray
        addSubviewWithAnchors(timeIcon, top: topAnchor, leading: speedLabel.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        timeLabel.textColor = .darkGray
        addSubviewWithAnchors(timeLabel, top: topAnchor, leading: timeIcon.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        
        pauseResumeButton.asIconButton("pause")
        pauseResumeButton.tintColor = .darkGray
        pauseResumeButton.addAction(UIAction(){ action in
            self.togglePauseResume()
        }, for: .touchDown)
        addSubviewWithAnchors(pauseResumeButton, top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
    }
    
    func startTrackInfo(){
        pauseResumeButton.asIconButton("pause")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTrackInfo(){
        if let track = TrackRecorder.track{
            distanceLabel.text = "\(Int(track.distance)) m"
            distanceUpLabel.text = "\(Int(track.upDistance)) m"
            distanceDownLabel.text = "\(Int(track.downDistance)) m"
            if let tp = track.trackpoints.last{
                speedLabel.text = "\(tp.kmhSpeed) km/h"
            }
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
    }
    
    @objc func updateTime(){
        if let track = TrackRecorder.track{
            timeLabel.text = track.durationUntilNow.hmString()
        }
    }
    
    func togglePauseResume(){
        delegate?.togglePauseTracking()
        pauseResumeButton.asIconButton(TrackRecorder.isRecording ? "pause" : "play")
        setNeedsLayout()
    }
    
}
