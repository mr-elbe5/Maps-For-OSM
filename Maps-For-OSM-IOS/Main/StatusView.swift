/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5IOSUI


class StatusView : UIView{
    
    var detailView = UIView()
    var defaultView = UIView()
    var detailButton = UIButton()
    
    var compassLabel : UILabel? = nil
    
    var isDetailed = false
    
    var coordinateLabel : UILabel? = nil
    var altitudeLabel : UILabel? = nil
    var gpsSpeed : UILabel? = nil
    var horizontalUncertaintyLabel : UILabel? = nil
    var verticalUncertaintyLabel : UILabel? = nil
    
    func setup(){
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
        if isDetailed{
            var label = UILabel(text: "\("coordinate".localize()):").withTextColor(.darkText)
            coordinateLabel = UILabel().withTextColor(.darkText)
            detailView.addSubviewWithAnchors(label, top: detailView.topAnchor, leading: detailView.leadingAnchor, insets: defaultInsets)
            detailView.addSubviewWithAnchors(coordinateLabel!, top: detailView.topAnchor, leading: label.trailingAnchor, insets: defaultInsets)
            var nextAnchor = label.bottomAnchor
            
            altitudeLabel = UILabel().withTextColor(.darkText)
            label = UILabel(text: "\("altitude".localize()):").withTextColor(.darkText)
            detailView.addSubviewWithAnchors(label, top: nextAnchor, leading: detailView.leadingAnchor, insets: defaultInsets)
            detailView.addSubviewWithAnchors(altitudeLabel!, top: nextAnchor, leading: label.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            
            gpsSpeed = UILabel().withTextColor(.darkText)
            label = UILabel(text: "\("speed".localize()):").withTextColor(.darkText)
            detailView.addSubviewWithAnchors(label, top: nextAnchor, leading: detailView.leadingAnchor, insets: defaultInsets)
            detailView.addSubviewWithAnchors(gpsSpeed!, top: nextAnchor, leading: label.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            
            horizontalUncertaintyLabel = UILabel().withTextColor(.darkText)
            label = UILabel(text: "\("horizontalUncertainty".localize()):").withTextColor(.darkText)
            detailView.addSubviewWithAnchors(label, top: nextAnchor, leading: detailView.leadingAnchor, insets: defaultInsets)
            detailView.addSubviewWithAnchors(horizontalUncertaintyLabel!, top: nextAnchor, leading: label.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            
            label.bottom(detailView.bottomAnchor)
        }
    }
    
    func setupDefaultView(){
        let compassIcon = UIImageView(image: UIImage(systemName: "safari"))
        compassIcon.tintColor = .darkText
        defaultView.addSubviewWithAnchors(compassIcon, top: defaultView.topAnchor, leading: defaultView.leadingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
        compassLabel = UILabel(text: "0°").withTextColor(.darkText)
        defaultView.addSubviewWithAnchors(compassLabel!, top: defaultView.topAnchor, leading: compassIcon.trailingAnchor, bottom: defaultView.bottomAnchor)
        
        detailButton.asIconButton(isDetailed ? "chevron.down.circle" : "chevron.up.circle", color: .darkText)
        detailButton.addAction(UIAction(){ action in
            self.toggleDetailed()
        }, for: .touchDown)
        defaultView.addSubviewWithAnchors(detailButton, top: defaultView.topAnchor, trailing: defaultView.trailingAnchor, bottom: defaultView.bottomAnchor, insets: flatInsets)
    }
    
    func updateDetailInfo(location: CLLocation){
        coordinateLabel?.text = location.coordinate.asString
        altitudeLabel?.text = "\(Int(location.altitude)) m"
        gpsSpeed?.text = "\(Int(max(0,location.speed*3.6))) km/h"
        horizontalUncertaintyLabel?.text = location.horizontalAccuracy < 0 ? "?" : "\(String(floor(location.horizontalAccuracy))) m"
    }
    
    func updateDirection(direction: CLLocationDirection) {
        if TrackRecorder.instance == nil{
            compassLabel?.text="\(Int(direction))°"
        }
    }
    
    func toggleDetailed(){
        isDetailed = !isDetailed
        setupDetailView()
        detailButton.asIconButton(isDetailed ? "chevron.down.circle" : "chevron.up.circle", color: .darkText)
        setNeedsLayout()
    }
    
}
