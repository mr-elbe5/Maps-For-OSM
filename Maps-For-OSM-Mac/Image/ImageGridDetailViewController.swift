/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import E5Data
import E5MapData


class ImageGridDetailViewController: PopoverViewController {
    
    init(image: Image){
        super.init()
        popover.behavior = .transient
        contentView = ImageGridDetailView(image: image, controller: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class ImageGridDetailView: NSView{
        
        var image: Image
        var controller: PopoverViewController
        
        let stackView = NSStackView()
        
        init(image: Image, controller: PopoverViewController) {
            self.image = image
            self.controller = controller
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func setupView(){
            image.readMetaData()
            stackView.orientation = .vertical
            stackView.alignment = .leading
            stackView.spacing = Insets.smallInset
            addSubviewFilling(stackView)
            let nameView = NSTextField(labelWithString: image.fileURL.lastPathComponent)
            let lensModelView = NSTextField(labelWithString: image.metaData?.cameraModel ?? "")
            let widthView = NSTextField(labelWithString: intString(val: image.metaData?.width) + " px")
            let heightView = NSTextField(labelWithString: intString(val: image.metaData?.height) + " px")
            let latitudeView = NSTextField(labelWithString: coordString(val: image.metaData?.latitude) + "°")
            let longitudeView = NSTextField(labelWithString: coordString(val: image.metaData?.longitude) + "°")
            let altitudeView = NSTextField(labelWithString: intString(val: image.metaData?.altitude) + " m")
            let exifCreationDateView = NSTextField(labelWithString: image.metaData?.dateTime?.dateTimeString() ?? "")
            addDataLine(name: "name", view: nameView)
            addDataLine(name: "camera", view: lensModelView)
            addDataLine(name: "width".localize(), view: widthView)
            addDataLine(name: "height".localize(), view: heightView)
            addDataLine(name: "latitude".localize(), view: latitudeView)
            addDataLine(name: "longitude".localize(), view: longitudeView)
            addDataLine(name: "altitude".localize(), view: altitudeView)
            addDataLine(name: "creationDate".localize(), view: exifCreationDateView)
        }
        
        func intString(val: Double?) -> String{
            if let val = val{
                return String(Int(val))
            }
            return ""
        }
        
        func coordString(val: Double?) -> String{
            if let val = val{
                return String(format: "%.5f", val)
            }
            return ""
        }
        
        func addDataLine(name: String, view: NSView){
            let line = NSView()
            let label = NSTextField(labelWithString: name.localize() + ": ")
            label.textColor = .white
            line.addSubview(label)
            label.setAnchors(top: line.topAnchor, leading: line.leadingAnchor, bottom: line.bottomAnchor)
            line.addSubview(view)
            view.setAnchors(top: line.topAnchor, leading: label.trailingAnchor, trailing: line.trailingAnchor, bottom: line.bottomAnchor)
            stackView.addArrangedSubview(line)
        }
        
    }
    
}
