/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5MapData
import E5IOSUI

public protocol PlaceDelegate{
    func placeChanged(place: Place)
    func placesChanged()
    func showPlaceOnMap(place: Place)
}

protocol PlaceCellDelegate{
    func editPlace(place: Place)
    func showPlaceOnMap(place: Place)
}

class PlaceCell: TableViewCell{
    
    static let CELL_IDENT = "placeCell"
    
    var place : Place? = nil
    
    var delegate: PlaceCellDelegate? = nil
    
    override open func setupCellBody(){
        cellBody.addSubviewFilling(itemView, insets: .zero)
        iconView.setBackground(UIColor(white: 1.0, alpha: 0.3)).setRoundedEdges()
        cellBody.addSubviewWithAnchors(iconView, top: iconView.bottomAnchor, trailing: cellBody.trailingAnchor, insets: smallInsets)
    }
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        if let place = place{
            let selectedButton = UIButton().asIconButton(place.selected ? "checkmark.square" : "square", color: .label)
            selectedButton.addAction(UIAction(){ action in
                place.selected = !place.selected
                selectedButton.setImage(UIImage(systemName: place.selected ? "checkmark.square" : "square"), for: .normal)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, trailing: iconView.trailingAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.delegate?.showPlaceOnMap(place: place)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(mapButton, top: iconView.topAnchor, trailing: selectedButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let editButton = UIButton().asIconButton("magnifyingglass", color: .label)
            editButton.addAction(UIAction(){ action in
                self.delegate?.editPlace(place: place)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(editButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: mapButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
        }
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        
        if let place = place{
            var topAnchor = itemView.topAnchor
            if !place.name.isEmpty{
                let header = UILabel(header: place.name)
                itemView.addSubviewWithAnchors(header, top: itemView.topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
                topAnchor = header.bottomAnchor
            }
            
            let locationLabel = UILabel(text: place.address)
            locationLabel.textAlignment = .center
            itemView.addSubviewWithAnchors(locationLabel, top: topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: defaultInsets)
            
            let coordinateLabel = UILabel(text: place.coordinate.asString)
            coordinateLabel.textAlignment = .center
            itemView.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: flatInsets)
            
            var lastView = coordinateLabel
            var text: UILabel
            var imageCount = 0
            var audioCount = 0
            var videoCount = 0
            var noteCount = 0
            var trackNames = Array<String>()
            for item in place.items{
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
                    if let track = item as? TrackItem{
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


