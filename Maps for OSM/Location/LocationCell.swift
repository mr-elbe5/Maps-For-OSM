/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit


protocol LocationCellDelegate{
    func deleteLocation(location: Location, approved: Bool)
    func viewLocation(location: Location)
    func showLocationOnMap(location: Location)
}

class LocationCell: UITableViewCell{
    
    var location : Location? = nil {
        didSet {
            updateCell()
        }
    }
    
    var delegate: LocationCellDelegate? = nil
    
    var cellBody = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        shouldIndentWhileEditing = false
        cellBody.setBackground(.white).setRoundedBorders()
        contentView.addSubviewFilling(cellBody, insets: defaultInsets)
        accessoryType = .none
        updateCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(isEditing: Bool = false){
        cellBody.removeAllSubviews()
        if let location = location{
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addTarget(self, action: #selector(deleteLocation), for: .touchDown)
            cellBody.addSubviewWithAnchors(deleteButton, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .systemBlue)
            viewButton.addTarget(self, action: #selector(viewLocation), for: .touchDown)
            cellBody.addSubviewWithAnchors(viewButton, top: cellBody.topAnchor, trailing: deleteButton.leadingAnchor, insets: defaultInsets)
            
            let mapButton = UIButton().asIconButton("map")
            mapButton.tintColor = UIColor.systemBlue
            mapButton.addTarget(self, action: #selector(showLocationOnMap), for: .touchDown)
            cellBody.addSubviewWithAnchors(mapButton, top: cellBody.topAnchor, trailing: viewButton.leadingAnchor, insets: defaultInsets)
            var nextAnchor = mapButton.bottomAnchor
            
            var label = UILabel()
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.text = location.address
            cellBody.addSubviewWithAnchors(label, top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            
            label = UILabel()
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.text = location.coordinateString
            cellBody.addSubviewWithAnchors(label, top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            
            if !description.isEmpty{
                label = UILabel()
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.text = location.description
                cellBody.addSubviewWithAnchors(label, top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
                nextAnchor = label.bottomAnchor
            }
            
            label = UILabel()
            label.text = String(location.photos.count) + " " + "photos".localize()
            cellBody.addSubviewWithAnchors(label, top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, bottom: cellBody.bottomAnchor, insets: defaultInsets)
        }
    }
    
    @objc func deleteLocation() {
        if let location = location{
            delegate?.deleteLocation(location: location, approved: false)
        }
    }
    
    @objc func viewLocation(){
        if location != nil{
            delegate?.viewLocation(location: location!)
        }
    }
    
    @objc func showLocationOnMap(){
        if location != nil{
            delegate?.showLocationOnMap(location: location!)
        }
    }
    
}


