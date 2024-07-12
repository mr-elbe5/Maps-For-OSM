/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5MapData
import E5IOSUI

public protocol LocationDelegate{
    func locationChanged(location: Location)
    func locationsChanged()
    func showLocationOnMap(location: Location)
}

protocol LocationCellDelegate{
    func editLocation(location: Location)
    func showLocationOnMap(location: Location)
}

class LocationCell: TableViewCell{
    
    static let CELL_IDENT = "locationCell"
    
    var location : Location? = nil
    
    var delegate: LocationCellDelegate? = nil
    
    override open func setupCellBody(){
        backgroundColor = .tableBackground
        cellBody.setBackground(.cellBackground).setRoundedBorders()
        iconView.setBackground(.iconViewColor).setRoundedEdges()
        cellBody.addSubviewWithAnchors(iconView, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: smallInsets)
        cellBody.addSubviewWithAnchors(itemView, top: iconView.bottomAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, bottom: cellBody.bottomAnchor, insets: .zero)
    }
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        if let location = location{
            let selectedButton = UIButton().asIconButton(location.selected ? "checkmark.square" : "square", color: .label)
            selectedButton.addAction(UIAction(){ action in
                location.selected = !location.selected
                selectedButton.setImage(UIImage(systemName: location.selected ? "checkmark.square" : "square"), for: .normal)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, trailing: iconView.trailingAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.delegate?.showLocationOnMap(location: location)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(mapButton, top: iconView.topAnchor, trailing: selectedButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let editButton = UIButton().asIconButton("magnifyingglass", color: .label)
            editButton.addAction(UIAction(){ action in
                self.delegate?.editLocation(location: location)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(editButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: mapButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
        }
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        
        if let location = location{
            var topAnchor = itemView.topAnchor
            if !location.name.isEmpty{
                let header = UILabel(header: location.name)
                itemView.addSubviewWithAnchors(header, top: itemView.topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
                topAnchor = header.bottomAnchor
            }
            
            let locationLabel = UILabel(text: location.address)
            locationLabel.textAlignment = .center
            itemView.addSubviewWithAnchors(locationLabel, top: topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
            
            let coordinateLabel = UILabel(text: location.coordinate.asString)
            coordinateLabel.textAlignment = .center
            itemView.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: flatInsets)
            
            var lastView = coordinateLabel
            var text: UILabel
            var imageCount = 0
            var audioCount = 0
            var videoCount = 0
            var noteCount = 0
            var trackNames = Array<String>()
            for item in location.items{
                switch item.type{
                case .image:
                    imageCount += 1
                case .audio:
                    audioCount += 1
                case .video:
                    videoCount += 1
                case .note:
                    noteCount += 1
                case .track:
                    if let track = item as? Track{
                        trackNames.append(track.name)
                    }
                }
            }
            
            if imageCount > 0{
                text = UILabel(text: "imageCount".localize() + String(imageCount))
                itemView.addSubviewWithAnchors(text, top: lastView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
                lastView = text
            }
            if audioCount > 0{
                text = UILabel(text: "audioCount".localize() + String(audioCount))
                itemView.addSubviewWithAnchors(text, top: lastView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
                lastView = text
            }
            if videoCount > 0{
                text = UILabel(text: "videoCount".localize() + String(videoCount))
                itemView.addSubviewWithAnchors(text, top: lastView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
                lastView = text
            }
            if noteCount > 0{
                text = UILabel(text: "noteCount".localize() + String(noteCount))
                itemView.addSubviewWithAnchors(text, top: lastView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
                lastView = text
            }
            for trackName in trackNames{
                text = UILabel(text: "trackListName".localize() + trackName)
                itemView.addSubviewWithAnchors(text, top: lastView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
                lastView = text
            }
            
            lastView.bottom(itemView.bottomAnchor, inset: -defaultInset)
            
        }
        
    }
    
}


