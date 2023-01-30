/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class StatusView : UIView{
    
    var distanceLabel = UILabel()
    var distanceUpLabel = UILabel()
    var distanceDownLabel = UILabel()
    var speedLabel = UILabel()
    var timeLabel = UILabel()
    
    var timer : Timer? = nil
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let distanceIcon = UIImageView(image: UIImage(systemName: "arrow.right"))
        distanceIcon.tintColor = .darkGray
        addSubviewWithAnchors(distanceIcon, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: flatInsets)
        distanceLabel.textColor = .darkGray
        distanceLabel.text = "0m"
        addSubviewWithAnchors(distanceLabel, top: topAnchor, leading: distanceIcon.trailingAnchor, bottom: bottomAnchor)
        
        let distanceUpIcon = UIImageView(image: UIImage(systemName: "arrow.up"))
        distanceUpIcon.tintColor = .darkGray
        addSubviewWithAnchors(distanceUpIcon, top: topAnchor, leading: distanceLabel.trailingAnchor, bottom: bottomAnchor, insets: flatInsets)
        distanceUpLabel.textColor = .darkGray
        distanceUpLabel.text = "0m"
        addSubviewWithAnchors(distanceUpLabel, top: topAnchor, leading: distanceUpIcon.trailingAnchor, bottom: bottomAnchor)
        
        let distanceDownIcon = UIImageView(image: UIImage(systemName: "arrow.down"))
        distanceDownIcon.tintColor = .darkGray
        addSubviewWithAnchors(distanceDownIcon, top: topAnchor, leading: distanceUpLabel.trailingAnchor, bottom: bottomAnchor, insets: flatInsets)
        distanceDownLabel.textColor = .darkGray
        distanceDownLabel.text = "0m"
        addSubviewWithAnchors(distanceDownLabel, top: topAnchor, leading: distanceDownIcon.trailingAnchor, bottom: bottomAnchor)
        
        let speedIcon = UIImageView(image: UIImage(systemName: "speedometer"))
        speedIcon.tintColor = .darkGray
        addSubviewWithAnchors(speedIcon, top: topAnchor, leading: distanceDownLabel.trailingAnchor, bottom: bottomAnchor, insets: flatInsets)
        speedLabel.textColor = .darkGray
        speedLabel.text = "0km/h"
        addSubviewWithAnchors(speedLabel, top: topAnchor, leading: speedIcon.trailingAnchor, bottom: bottomAnchor)
        
        let timeIcon = UIImageView(image: UIImage(systemName: "stopwatch"))
        timeIcon.tintColor = .darkGray
        addSubviewWithAnchors(timeIcon, top: topAnchor, leading: speedLabel.trailingAnchor, bottom: bottomAnchor, insets: flatInsets)
        timeLabel.textColor = .darkGray
        addSubviewWithAnchors(timeLabel, top: topAnchor, leading: timeIcon.trailingAnchor, bottom: bottomAnchor)
        
        updateInfo()
        isHidden = true
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
            if let tp = track.trackpoints.last{
                speedLabel.text = "\(tp.kmhSpeed)km/h"
                speedLabel.textColor = tp.valid ? .darkGray : .red
            }
        }
    }
    
    func pauseInfo(){
        timer?.invalidate()
        timer = nil
    }
    
    func resumeInfo(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
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
    
}
