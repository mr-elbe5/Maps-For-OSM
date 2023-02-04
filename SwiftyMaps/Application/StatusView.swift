/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class StatusView : UIView{
    
    var detailView = UIView()
    var defaultView = UIView()
    var detailButton = UIButton()
    
    var distanceLabel = UILabel()
    var distanceUpLabel = UILabel()
    var distanceDownLabel = UILabel()
    var speedLabel = UILabel()
    var timeLabel = UILabel()
    
    var compassLabel = UILabel()
    
    var timer : Timer? = nil
    
    var isDetailed = false
    
    var coordinateLabel = UILabel()
    var altitudeLabel = UILabel()
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        distanceLabel.textColor = .darkGray
        distanceUpLabel.textColor = .darkGray
        distanceDownLabel.textColor = .darkGray
        speedLabel.textColor = .darkGray
        timeLabel.textColor = .darkGray
        compassLabel.textColor = .darkGray
        
        addSubviewWithAnchors(detailView, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: .zero)
        addSubviewWithAnchors(defaultView, top: detailView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        setupDetailView()
        setupDefaultView()
    }
    
    func setupDetailView(){
        detailView.removeAllSubviews()
        if isDetailed{
            var label = UILabel(text: "\("coordinate".localize()):")
            detailView.addSubviewWithAnchors(label, top: detailView.topAnchor, leading: detailView.leadingAnchor, insets: defaultInsets)
            detailView.addSubviewWithAnchors(coordinateLabel, top: detailView.topAnchor, leading: label.trailingAnchor, insets: defaultInsets)
            var nextAnchor = label.bottomAnchor
            label = UILabel(text: "\("altitude".localize()):")
            detailView.addSubviewWithAnchors(label, top: nextAnchor, leading: detailView.leadingAnchor, insets: defaultInsets)
            detailView.addSubviewWithAnchors(altitudeLabel, top: nextAnchor, leading: label.trailingAnchor, insets: defaultInsets)
                .bottom(detailView.bottomAnchor)
            nextAnchor = label.bottomAnchor
            label.bottom(detailView.bottomAnchor)
        }
    }
    
    func setupDefaultView(){
        defaultView.removeAllSubviews()
        if TrackRecorder.track != nil{
            let distanceIcon = UIImageView(image: UIImage(systemName: "arrow.right"))
            distanceIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(distanceIcon, top: defaultView.topAnchor, leading: defaultView.leadingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            distanceLabel.text = "0m"
            addSubviewWithAnchors(distanceLabel, top: defaultView.topAnchor, leading: distanceIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
            
            let distanceUpIcon = UIImageView(image: UIImage(systemName: "arrow.up"))
            distanceUpIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(distanceUpIcon, top: defaultView.topAnchor, leading: distanceLabel.trailingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            
            distanceUpLabel.text = "0m"
            addSubviewWithAnchors(distanceUpLabel, top: defaultView.topAnchor, leading: distanceUpIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
            
            let distanceDownIcon = UIImageView(image: UIImage(systemName: "arrow.down"))
            distanceDownIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(distanceDownIcon, top: defaultView.topAnchor, leading: distanceUpLabel.trailingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            
            distanceDownLabel.text = "0m"
            addSubviewWithAnchors(distanceDownLabel, top: defaultView.topAnchor, leading: distanceDownIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
            
            let speedIcon = UIImageView(image: UIImage(systemName: "speedometer"))
            speedIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(speedIcon, top: defaultView.topAnchor, leading: distanceDownLabel.trailingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            
            speedLabel.text = "0km/h"
            addSubviewWithAnchors(speedLabel, top: defaultView.topAnchor, leading: speedIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
            
            let timeIcon = UIImageView(image: UIImage(systemName: "stopwatch"))
            timeIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(timeIcon, top: defaultView.topAnchor, leading: speedLabel.trailingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            
            addSubviewWithAnchors(timeLabel, top: defaultView.topAnchor, leading: timeIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
        }
        else{
            let compassIcon = UIImageView(image: UIImage(systemName: "safari"))
            compassIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(compassIcon, top: defaultView.topAnchor, leading: defaultView.leadingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            compassLabel.text = "0°"
            defaultView.addSubviewWithAnchors(compassLabel, top: defaultView.topAnchor, leading: compassIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
        }
        
        detailButton.asIconButton(isDetailed ? "arrowtriangle.down" : "arrowtriangle.up")
        detailButton.tintColor = .darkGray
        detailButton.addTarget(self, action: #selector(toggleDetailed), for: .touchDown)
        defaultView.addSubviewWithAnchors(detailButton, top: defaultView.topAnchor, trailing: defaultView.trailingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
    }
    
    func startTrackInfo(){
        setupDefaultView()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTrackInfo(){
        if let track = TrackRecorder.track{
            distanceLabel.text = "\(Int(track.distance))m"
            distanceUpLabel.text = "\(Int(track.upDistance))m"
            distanceDownLabel.text = "\(Int(track.downDistance))m"
            if let tp = track.trackpoints.last{
                speedLabel.text = "\(tp.kmhSpeed)km/h"
            }
        }
    }
    
    func updateDetailInfo(location: CLLocation){
        coordinateLabel.text = location.coordinate.asString
        altitudeLabel.text = "\(Int(location.altitude))m"
    }
    
    func updateDirection(direction: CLLocationDirection) {
        if TrackRecorder.track == nil{
            compassLabel.text="\(Int(direction))°"
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
        setupDefaultView()
    }
    
    @objc func updateTime(){
        if let track = TrackRecorder.track{
            timeLabel.text = track.durationUntilNow.hmsString()
        }
    }
    
    @objc func toggleDetailed(){
        isDetailed = !isDetailed
        setupDetailView()
        detailButton.asIconButton(isDetailed ? "arrowtriangle.down" : "arrowtriangle.up")
        setNeedsLayout()
    }
    
}
