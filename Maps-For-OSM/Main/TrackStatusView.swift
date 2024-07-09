/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5IOSUI
import E5MapData

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
    
    var zeroHeightConstraint: NSLayoutConstraint? = nil
    
    var delegate: TrackStatusDelegate? = nil
    
    func setup(){
        backgroundColor = UIStatics.transparentBackground
        layer.masksToBounds = true
        zeroHeightConstraint = heightAnchor.constraint(equalToConstant: 0)
        
        let distanceIcon = UIImageView(image: UIImage(systemName: "arrow.right"))
        distanceIcon.tintColor = .label
        addSubviewWithAnchors(distanceIcon, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: smallInsets)
        distanceLabel.textColor = .label
        addSubviewWithAnchors(distanceLabel, top: topAnchor, leading: distanceIcon.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        
        let distanceUpIcon = UIImageView(image: UIImage(systemName: "arrow.up"))
        distanceUpIcon.tintColor = .label
        addSubviewWithAnchors(distanceUpIcon, top: topAnchor, leading: distanceLabel.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        distanceUpLabel.textColor = .label
        addSubviewWithAnchors(distanceUpLabel, top: topAnchor, leading: distanceUpIcon.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        
        let distanceDownIcon = UIImageView(image: UIImage(systemName: "arrow.down"))
        distanceDownIcon.tintColor = .label
        addSubviewWithAnchors(distanceDownIcon, top: topAnchor, leading: distanceUpLabel.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        distanceDownLabel.textColor = .label
        addSubviewWithAnchors(distanceDownLabel, top: topAnchor, leading: distanceDownIcon.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        
        let speedIcon = UIImageView(image: UIImage(systemName: "speedometer"))
        speedIcon.tintColor = .label
        addSubviewWithAnchors(speedIcon, top: topAnchor, leading: distanceDownLabel.trailingAnchor, bottom: bottomAnchor, insets: flatInsets)
        speedLabel.textColor = .label
        addSubviewWithAnchors(speedLabel, top: topAnchor, leading: speedIcon.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        
        let timeIcon = UIImageView(image: UIImage(systemName: "stopwatch"))
        timeIcon.tintColor = .label
        addSubviewWithAnchors(timeIcon, leading: speedLabel.trailingAnchor, insets: smallInsets)
            .centerY(centerYAnchor)
        timeLabel.textColor = .label
        addSubviewWithAnchors(timeLabel, top: topAnchor, leading: timeIcon.trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
        
        pauseResumeButton.asIconButton("pause.circle")
        pauseResumeButton.tintColor = .label
        pauseResumeButton.addAction(UIAction(){ action in
            self.togglePauseResume()
        }, for: .touchDown)
        addSubviewWithAnchors(pauseResumeButton, top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: smallInsets)
    }
    
    func hide(_ flag: Bool){
        isHidden = flag
        zeroHeightConstraint?.isActive = flag
    }
    
    func startTrackInfo(){
        pauseResumeButton.asIconButton("pause.circle")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTrackInfo(){
        if let track = TrackRecorder.instance?.track{
            distanceLabel.text = "\(Int(track.distance)) m"
            distanceUpLabel.text = "\(Int(track.upDistance)) m"
            distanceDownLabel.text = "\(Int(track.downDistance)) m"
            speedLabel.text = "\(TrackRecorder.instance?.kmhSpeed ?? 0) km/h"
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
        if let track = TrackRecorder.instance?.track{
            timeLabel.text = track.durationUntilNow.hmString()
        }
    }
    
    func togglePauseResume(){
        delegate?.togglePauseTracking()
        pauseResumeButton.asIconButton(TrackRecorder.isRecording ? "pause.circle" : "play.circle")
    }
    
}
