/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import E5MapData

class EditNoteViewController: ViewController {
    
    var noteEditField = NSTextField()
    
    var note: Note
    
    init(note: Note){
        self.note = note
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 0))
        let header = NSTextField(labelWithString: "editNote".localize()).asHeadline()
        view.addSubviewWithAnchors(header, top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        noteEditField.asEditableField(text: note.text)
        view.addSubviewWithAnchors(noteEditField, top: header.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
            .height(100)
        let saveButton = NSButton(title: "save".localize(), target: self, action: #selector(save))
        view.addSubviewWithAnchors(saveButton, top: noteEditField.bottomAnchor, bottom: view.bottomAnchor, insets: defaultInsets)
            .centerX(view.centerXAnchor)
    }
    
    @objc func save(){
        note.text = noteEditField.stringValue
        NSApp.stopModal(withCode: .OK)
        self.view.window?.close()
    }
    
}
