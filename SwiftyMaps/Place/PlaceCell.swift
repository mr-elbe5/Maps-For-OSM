/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit


protocol PlaceCellDelegate{
    func deletePlace(place: Place, approved: Bool)
    func viewPlace(place: Place)
    func showOnMap(place: Place)
}

class PlaceCell: UITableViewCell{
    
    var place : Place? = nil {
        didSet {
            updateCell()
        }
    }
    
    var delegate: PlaceCellDelegate? = nil
    
    var cellBody = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        shouldIndentWhileEditing = false
        cellBody.backgroundColor = .white
        cellBody.layer.cornerRadius = 5
        contentView.addSubview(cellBody)
        cellBody.fillView(view: contentView, insets: defaultInsets)
        accessoryType = .none
        updateCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(isEditing: Bool = false){
        cellBody.removeAllSubviews()
        if let location = place{
            let deleteButton = IconButton(icon: "xmark.circle")
            deleteButton.tintColor = UIColor.systemRed
            deleteButton.addTarget(self, action: #selector(deletePlace), for: .touchDown)
            cellBody.addSubview(deleteButton)
            deleteButton.setAnchors(top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            let viewButton = IconButton(icon: "magnifyingglass", tintColor: .systemBlue)
            viewButton.addTarget(self, action: #selector(viewPlace), for: .touchDown)
            cellBody.addSubview(viewButton)
            viewButton.setAnchors(top: cellBody.topAnchor, trailing: deleteButton.leadingAnchor, insets: defaultInsets)
            let mapButton = IconButton(icon: "map")
            mapButton.tintColor = UIColor.systemBlue
            mapButton.addTarget(self, action: #selector(showOnMap), for: .touchDown)
            cellBody.addSubview(mapButton)
            mapButton.setAnchors(top: cellBody.topAnchor, trailing: viewButton.leadingAnchor, insets: defaultInsets)
            var nextAnchor = mapButton.bottomAnchor
            var label = UILabel()
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.text = location.address
            cellBody.addSubview(label)
            label.setAnchors(top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            label = UILabel()
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.text = location.coordinateString
            cellBody.addSubview(label)
            label.setAnchors(top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            nextAnchor = label.bottomAnchor
            if !description.isEmpty{
                label = UILabel()
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.text = location.description
                cellBody.addSubview(label)
                label.setAnchors(top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
                nextAnchor = label.bottomAnchor
            }
            label = UILabel()
            label.text = String(location.photos.count) + " " + "photos".localize()
            cellBody.addSubview(label)
            label.setAnchors(top: nextAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, bottom: cellBody.bottomAnchor, insets: defaultInsets)
        }
    }
    
    @objc func deletePlace() {
        if let location = place{
            delegate?.deletePlace(place: location, approved: false)
        }
    }
    
    @objc func viewPlace(){
        if place != nil{
            delegate?.viewPlace(place: place!)
        }
    }
    
    @objc func showOnMap(){
        if place != nil{
            delegate?.showOnMap(place: place!)
        }
    }
    
}


