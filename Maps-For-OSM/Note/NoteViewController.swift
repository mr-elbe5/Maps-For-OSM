/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5IOSUI

protocol NoteViewDelegate{
    func addNote(text: String, coordinate: CLLocationCoordinate2D)
}

class NoteViewController: NavScrollViewController{
    
    var coordinate : CLLocationCoordinate2D
    var noteEditView = TextEditArea().defaultWithBorder()
    
    var delegate: NoteViewDelegate? = nil
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
        super.init()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "note".localize()
        super.loadView()
        setupKeyboard()
    }
    
    override func loadScrollableSubviews() {
        contentView.addSubviewWithAnchors(noteEditView, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
            
        let saveButton = UIButton().asTextButton("save".localize()).withTextColor(color: .systemBlue)
            saveButton.addAction(UIAction(){ action in
                self.save()
            }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: noteEditView.bottomAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
                .centerX(contentView.centerXAnchor)
    }
    
    func save(){
        self.close()
        delegate?.addNote(text: noteEditView.text, coordinate: coordinate)
    }
    
}



