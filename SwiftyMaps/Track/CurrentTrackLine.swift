/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class CurrentTrackLine : UIView{
    
    var distanceLabel = UILabel()
    var distanceUpLabel = UILabel()
    var distanceDownLabel = UILabel()
    var timeLabel = UILabel()
    
    var pauseResumeButton = UIButton()
    
    var timer : Timer? = nil
    
    func setup(){
        backgroundColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let distanceIcon = UIImageView(image: UIImage(systemName: "arrow.right"))
        distanceIcon.tintColor = .darkGray
        addSubview(distanceIcon)
        distanceIcon.setAnchors(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: flatInsets)
        distanceLabel.textColor = .darkGray
        distanceLabel.text = "0m"
        addSubview(distanceLabel)
        distanceLabel.setAnchors(top: topAnchor, leading: distanceIcon.trailingAnchor, bottom: bottomAnchor)
        
        let distanceUpIcon = UIImageView(image: UIImage(systemName: "arrow.up"))
        distanceUpIcon.tintColor = .darkGray
        addSubview(distanceUpIcon)
        distanceUpIcon.setAnchors(top: topAnchor, leading: distanceLabel.trailingAnchor, bottom: bottomAnchor, insets: flatInsets)
        distanceUpLabel.textColor = .darkGray
        distanceUpLabel.text = "0m"
        addSubview(distanceUpLabel)
        distanceUpLabel.setAnchors(top: topAnchor, leading: distanceUpIcon.trailingAnchor, bottom: bottomAnchor)
        
        let distanceDownIcon = UIImageView(image: UIImage(systemName: "arrow.down"))
        distanceDownIcon.tintColor = .darkGray
        addSubview(distanceDownIcon)
        distanceDownIcon.setAnchors(top: topAnchor, leading: distanceUpLabel.trailingAnchor, bottom: bottomAnchor, insets: flatInsets)
        distanceDownLabel.textColor = .darkGray
        distanceDownLabel.text = "0m"
        addSubview(distanceDownLabel)
        distanceDownLabel.setAnchors(top: topAnchor, leading: distanceDownIcon.trailingAnchor, bottom: bottomAnchor)
        
        let timeIcon = UIImageView(image: UIImage(systemName: "stopwatch"))
        timeIcon.tintColor = .darkGray
        addSubview(timeIcon)
        timeIcon.setAnchors(top: topAnchor, leading: distanceDownLabel.trailingAnchor, bottom: bottomAnchor, insets: flatInsets)
        timeLabel.textColor = .darkGray
        addSubview(timeLabel)
        timeLabel.setAnchors(top: topAnchor, leading: timeIcon.trailingAnchor, bottom: bottomAnchor)
        
        pauseResumeButton.tintColor = .darkGray
        addSubview(pauseResumeButton)
        pauseResumeButton.setAnchors(top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: flatInsets)
        updatePauseResumeButton()
        pauseResumeButton.addTarget(self, action: #selector(pauseResume), for: .touchDown)
        
        updateInfo()
        self.isHidden = true
    }
    
    func startInfo(){
        self.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateInfo(){
        if let track = TrackRecorder.track{
            distanceLabel.text = "\(Int(track.distance))m"
            distanceUpLabel.text = "\(Int(track.upDistance))m"
            distanceDownLabel.text = "\(Int(track.downDistance))m"
        }
    }
    
    func stopInfo(){
        self.isHidden = true
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateTime(){
        if let track = TrackRecorder.track{
            timeLabel.text = track.durationUntilNow.hmsString()
        }
    }
    
    @objc func pauseResume(){
        if let _ = TrackRecorder.track{
            if TrackRecorder.isRecording{
                TrackRecorder.pauseRecording()
            }
            else{
                TrackRecorder.resumeRecording()
            }
            updatePauseResumeButton()
        }
    }
    
    func updatePauseResumeButton(){
        if TrackRecorder.isRecording{
            pauseResumeButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
        else{
            pauseResumeButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }
    
}
