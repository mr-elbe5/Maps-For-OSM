/*
 Maps For OSM
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
    
    var distanceLabel : UILabel? = nil
    var distanceUpLabel : UILabel? = nil
    var distanceDownLabel : UILabel? = nil
    var speedLabel : UILabel? = nil
    var timeLabel : UILabel? = nil
    
    var compassLabel : UILabel? = nil
    
    var timer : Timer? = nil
    
    var isDetailed = false
    
    var coordinateLabel : UILabel? = nil
    var altitudeLabel : UILabel? = nil
    var gpsSpeed : UILabel? = nil
    var horizontalUncertaintyLabel : UILabel? = nil
    var verticalUncertaintyLabel : UILabel? = nil
    var speedUncertaintyFactorLabel : UILabel? = nil
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        addSubviewWithAnchors(detailView, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: .zero)
        addSubviewWithAnchors(defaultView, top: detailView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        setupDetailView()
        setupDefaultView()
    }
    
    func setupDetailView(){
        detailView.removeAllSubviews()
        coordinateLabel = nil
        altitudeLabel = nil
        gpsSpeed = nil
        horizontalUncertaintyLabel = nil
        verticalUncertaintyLabel = nil
        speedUncertaintyFactorLabel = nil
        if isDetailed{
            var label = UILabel(text: "\("coordinate".localize()):")
            coordinateLabel = UILabel()
            detailView.addSubviewWithAnchors(label, top: detailView.topAnchor, leading: detailView.leadingAnchor, insets: defaultInsets)
            detailView.addSubviewWithAnchors(coordinateLabel!, top: detailView.topAnchor, leading: label.trailingAnchor, insets: defaultInsets)
            var nextAnchor = label.bottomAnchor
            
            altitudeLabel = UILabel()
            label = UILabel(text: "\("altitude".localize()):")
            detailView.addSubviewWithAnchors(label, top: nextAnchor, leading: detailView.leadingAnchor, insets: defaultInsets)
            detailView.addSubviewWithAnchors(altitudeLabel!, top: nextAnchor, leading: label.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            
            gpsSpeed = UILabel()
            label = UILabel(text: "\("speed".localize()):")
            detailView.addSubviewWithAnchors(label, top: nextAnchor, leading: detailView.leadingAnchor, insets: defaultInsets)
            detailView.addSubviewWithAnchors(gpsSpeed!, top: nextAnchor, leading: label.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            
            horizontalUncertaintyLabel = UILabel()
            label = UILabel(text: "\("horizontalUncertainty".localize()):")
            detailView.addSubviewWithAnchors(label, top: nextAnchor, leading: detailView.leadingAnchor, insets: defaultInsets)
            detailView.addSubviewWithAnchors(horizontalUncertaintyLabel!, top: nextAnchor, leading: label.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            
            speedUncertaintyFactorLabel = UILabel()
            label = UILabel(text: "\("speedUncertaintyFactor".localize()):")
            detailView.addSubviewWithAnchors(label, top: nextAnchor, leading: detailView.leadingAnchor, insets: defaultInsets)
            detailView.addSubviewWithAnchors(speedUncertaintyFactorLabel!, top: nextAnchor, leading: label.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            
            label = UILabel(text: "\("positionValidityHint".localize())")
            label.numberOfLines = 0
            detailView.addSubviewWithAnchors(label, top: nextAnchor, leading: detailView.leadingAnchor, trailing: detailView.trailingAnchor, insets: defaultInsets)
            label.bottom(detailView.bottomAnchor)
        }
    }
    
    func setupDefaultView(){
        defaultView.removeAllSubviews()
        distanceLabel = nil
        distanceUpLabel = nil
        distanceDownLabel = nil
        speedLabel = nil
        timeLabel = nil
        compassLabel = nil
        
        if TrackRecorder.track != nil{
            let distanceIcon = UIImageView(image: UIImage(systemName: "arrow.right"))
            distanceIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(distanceIcon, top: defaultView.topAnchor, leading: defaultView.leadingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            distanceLabel = UILabel(text: "0 m")
            distanceLabel!.textColor = .darkGray
            defaultView.addSubviewWithAnchors(distanceLabel!, top: defaultView.topAnchor, leading: distanceIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
            
            let distanceUpIcon = UIImageView(image: UIImage(systemName: "arrow.up"))
            distanceUpIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(distanceUpIcon, top: defaultView.topAnchor, leading: distanceLabel!.trailingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            distanceUpLabel = UILabel(text: "0 m")
            distanceUpLabel!.textColor = .darkGray
            defaultView.addSubviewWithAnchors(distanceUpLabel!, top: defaultView.topAnchor, leading: distanceUpIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
            
            let distanceDownIcon = UIImageView(image: UIImage(systemName: "arrow.down"))
            distanceDownIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(distanceDownIcon, top: defaultView.topAnchor, leading: distanceUpLabel!.trailingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            distanceDownLabel = UILabel(text: "0 m")
            distanceDownLabel!.textColor = .darkGray
            defaultView.addSubviewWithAnchors(distanceDownLabel!, top: defaultView.topAnchor, leading: distanceDownIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
            
            let speedIcon = UIImageView(image: UIImage(systemName: "speedometer"))
            speedIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(speedIcon, top: defaultView.topAnchor, leading: distanceDownLabel!.trailingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            speedLabel = UILabel(text: "0 km/h")
            speedLabel!.textColor = .darkGray
            defaultView.addSubviewWithAnchors(speedLabel!, top: defaultView.topAnchor, leading: speedIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
            
            let timeIcon = UIImageView(image: UIImage(systemName: "stopwatch"))
            timeIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(timeIcon, top: defaultView.topAnchor, leading: speedLabel!.trailingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            timeLabel = UILabel()
            timeLabel!.textColor = .darkGray
            defaultView.addSubviewWithAnchors(timeLabel!, top: defaultView.topAnchor, leading: timeIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
        }
        else{
            let compassIcon = UIImageView(image: UIImage(systemName: "safari"))
            compassIcon.tintColor = .darkGray
            defaultView.addSubviewWithAnchors(compassIcon, top: defaultView.topAnchor, leading: defaultView.leadingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
            compassLabel = UILabel(text: "0°")
            compassLabel!.textColor = .darkGray
            defaultView.addSubviewWithAnchors(compassLabel!, top: defaultView.topAnchor, leading: compassIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
        }
        
        detailButton.asIconButton(isDetailed ? "arrowtriangle.down" : "arrowtriangle.up")
        detailButton.tintColor = .darkGray
        detailButton.addTarget(self, action: #selector(toggleDetailed), for: .touchDown)
        defaultView.addSubviewWithAnchors(detailButton, top: defaultView.topAnchor, trailing: defaultView.trailingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
    }
    
    func startTrackInfo(){
        setupDefaultView()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        setNeedsLayout()
    }
    
    func updateTrackInfo(){
        if let track = TrackRecorder.track{
            distanceLabel?.text = "\(Int(track.distance)) m"
            distanceUpLabel?.text = "\(Int(track.upDistance)) m"
            distanceDownLabel?.text = "\(Int(track.downDistance)) m"
            if let tp = track.trackpoints.last{
                speedLabel?.text = "\(tp.kmhSpeed) km/h"
            }
        }
    }
    
    func updateDetailInfo(location: CLLocation){
        coordinateLabel?.text = location.coordinate.asString
        altitudeLabel?.text = "\(Int(location.altitude)) m"
        gpsSpeed?.text = "\(Int(max(0,location.speed*3.6))) km/h"
        horizontalUncertaintyLabel?.text = location.horizontalAccuracy < 0 ? "?" : "\(String(floor(location.horizontalAccuracy))) m"
        horizontalUncertaintyLabel?.textColor = location.horizontalAccuracyValid ? .darkGray : .red
        var s = "?"
        if location.speedAccuracy > 0 && location.speedAccuracyValid{
            s = String(floor(location.speedAccuracy))
        }
        speedUncertaintyFactorLabel?.text = s
        speedUncertaintyFactorLabel?.textColor = location.speedAccuracyValid ? .darkGray : .red
    }
    
    func updateDirection(direction: CLLocationDirection) {
        if TrackRecorder.track == nil{
            compassLabel?.text="\(Int(direction))°"
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
        setNeedsLayout()
    }
    
    @objc func updateTime(){
        if let track = TrackRecorder.track{
            timeLabel?.text = track.durationUntilNow.hmsString()
        }
    }
    
    @objc func toggleDetailed(){
        isDetailed = !isDetailed
        setupDetailView()
        detailButton.asIconButton(isDetailed ? "arrowtriangle.down" : "arrowtriangle.up")
        setNeedsLayout()
    }
    
}
