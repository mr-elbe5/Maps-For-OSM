/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

protocol NoteViewDelegate{
    func addNote(note: String, coordinate: CLLocationCoordinate2D)
}

class NoteViewController: PopupScrollViewController{
    
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
        title = "place".localize()
        super.loadView()
        
        contentView.addSubviewWithAnchors(noteEditView, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
            
        let saveButton = UIButton().asTextButton("save".localize(), color: .systemBlue)
            saveButton.addAction(UIAction(){ action in
                self.save()
            }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: noteEditView.bottomAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
                .centerX(contentView.centerXAnchor)
        
        setupKeyboard()
    }
    
    func save(){
        self.dismiss(animated: false)
        delegate?.addNote(note: noteEditView.text, coordinate: coordinate)
    }
    
}



