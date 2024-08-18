/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVKit
import E5MapData

protocol AudioCellDelegate{
    func editAudio(_ audio: Audio)
}

class AudioCellView : LocationItemCellView{
    
    var audio: Audio
    
    var selectedButton: NSButton!
    
    var delegate: AudioCellDelegate? = nil
    
    init(audio:Audio){
        self.audio = audio
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        let titleField = NSTextField(wrappingLabelWithString: "audio".localize()).asHeadline()
        addSubviewWithAnchors(titleField, top: topAnchor, insets: smallInsets).centerX(centerXAnchor)
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor)
        let editButton = NSButton(icon: "pencil", target: self, action: #selector(editAudio))
        iconBar.addArrangedSubview(editButton)
        selectedButton = NSButton(icon: audio.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        let audioView = AVPlayerView()
        audioView.player = AVPlayer(url: audio.fileURL)
        addSubviewWithAnchors(audioView, top: iconBar.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        var lastView: NSView = audioView
        if !audio.comment.isEmpty{
            let label = NSTextField(wrappingLabelWithString: audio.comment)
            addSubviewWithAnchors(label, top: lastView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            lastView = label
        }
        lastView.bottom(bottomAnchor)
    }
    
    override func updateIconView() {
        selectedButton.image = NSImage(systemSymbolName: audio.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func editAudio(){
        delegate?.editAudio(audio)
    }
    
    @objc func selectionChanged(){
        audio.selected = !audio.selected
        updateIconView()
    }
    
}
