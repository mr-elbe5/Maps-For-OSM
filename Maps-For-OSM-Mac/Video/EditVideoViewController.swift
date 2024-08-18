/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import AVKit
import E5MapData

class EditVideoViewController: ViewController {
    
    var video: Video
    
    let videoPlayerView = AVPlayerView()
    
    var commentEditField = NSTextField()
    
    init(video: Video){
        self.video = video
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        videoPlayerView.player = nil
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 0))
        var header = NSTextField(labelWithString: "editVideo".localize()).asHeadline()
        view.addSubviewWithAnchors(header, top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        videoPlayerView.player = AVPlayer(url: video.fileURL)
        view.addSubviewWithAnchors(videoPlayerView, top: header.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
            .height(300)
        header = NSTextField(labelWithString: "comment".localize()).asLabel()
        view.addSubviewWithAnchors(header, top: videoPlayerView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        commentEditField.asEditableField(text: video.comment)
        view.addSubviewWithAnchors(commentEditField, top: header.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
            .height(100)
        let saveButton = NSButton(title: "save".localize(), target: self, action: #selector(save))
        view.addSubviewWithAnchors(saveButton, top: commentEditField.bottomAnchor, bottom: view.bottomAnchor, insets: defaultInsets)
            .centerX(view.centerXAnchor)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        videoPlayerView.player?.pause()
    }
    
    @objc func save(){
        video.comment = commentEditField.stringValue
        AppData.shared.save()
        NSApp.stopModal(withCode: .OK)
        self.view.window?.close()
    }
    
}
