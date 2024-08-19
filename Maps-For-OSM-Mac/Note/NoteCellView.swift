/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit



protocol NoteCellDelegate{
    func editNote(_ note: Note)
}

class NoteCellView : LocationItemCellView{
    
    var note: Note
    
    var selectedButton: NSButton!
    
    var delegate: NoteCellDelegate? = nil
    
    init(note: Note){
        self.note = note
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        let titleField = NSTextField(wrappingLabelWithString: "note".localize()).asHeadline()
        addSubviewWithAnchors(titleField, top: topAnchor, insets: smallInsets).centerX(centerXAnchor)
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor)
        let editButton = NSButton(icon: "pencil", target: self, action: #selector(editNote))
        iconBar.addArrangedSubview(editButton)
        selectedButton = NSButton(icon: note.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        let noteField = NSTextField(wrappingLabelWithString: note.text)
        addSubviewWithAnchors(noteField, top: iconBar.bottomAnchor,trailing: trailingAnchor, bottom: bottomAnchor)
            .width(widthAnchor)
    }
    
    override func updateIconView() {
        selectedButton.image = NSImage(systemSymbolName: note.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func editNote(){
        delegate?.editNote(note)
    }
    
    @objc func selectionChanged(){
        note.selected = !note.selected
        updateIconView()
    }
    
}
