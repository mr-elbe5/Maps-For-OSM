/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVKit


class EditAudioViewController: ViewController {
    
    var audio: AudioItem
    
    var commentEditField = NSTextField()
    
    init(audio: AudioItem){
        self.audio = audio
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 0))
        var header = NSTextField(labelWithString: "editAudio".localize()).asHeadline()
        view.addSubviewWithAnchors(header, top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        let audioView = AVPlayerView()
        audioView.player = AVPlayer(url: audio.fileURL)
        view.addSubviewWithAnchors(audioView, top: header.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        header = NSTextField(labelWithString: "title".localize()).asLabel()
        view.addSubviewWithAnchors(header, top: audioView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        commentEditField.asEditableField(text: audio.comment)
        view.addSubviewWithAnchors(commentEditField, top: header.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
            .height(100)
        let saveButton = NSButton(title: "save".localize(), target: self, action: #selector(save))
        view.addSubviewWithAnchors(saveButton, top: commentEditField.bottomAnchor, bottom: view.bottomAnchor, insets: defaultInsets)
            .centerX(view.centerXAnchor)
    }
    
    @objc func save(){
        audio.comment = commentEditField.stringValue
        AppData.shared.save()
        NSApp.stopModal(withCode: .OK)
        self.view.window?.close()
    }
    
}
