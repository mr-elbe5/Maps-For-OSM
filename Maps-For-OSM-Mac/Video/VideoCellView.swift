/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import AVKit
import E5MapData

protocol VideoCellDelegate{
    func editVideo(_ video: Video)
}

class VideoCellView : LocationItemCellView{
    
    var video: Video
    
    var selectedButton: NSButton!
    let videoPlayerView = AVPlayerView()
    
    var delegate: VideoCellDelegate? = nil
    
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
    
    override func viewDidHide() {
        super.viewDidHide()
        videoPlayerView.player?.pause()
    }
    
    override func setupView() {
        super.setupView()
        let titleField = NSTextField(wrappingLabelWithString: "video".localize()).asHeadline()
        addSubviewWithAnchors(titleField, top: topAnchor, insets: smallInsets).centerX(centerXAnchor)
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor)
        let showButton = NSButton(icon: "magnifyingglass", target: self, action: #selector(showVideo))
        iconBar.addArrangedSubview(showButton)
        let editButton = NSButton(icon: "pencil", target: self, action: #selector(editVideo))
        iconBar.addArrangedSubview(editButton)
        selectedButton = NSButton(icon: video.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        videoPlayerView.player = AVPlayer(url: video.fileURL)
        addSubviewWithAnchors(videoPlayerView, top: iconBar.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            .height(300)
        var lastView: NSView = videoPlayerView
        if !video.comment.isEmpty{
            let label = NSTextField(wrappingLabelWithString: video.comment)
            addSubviewWithAnchors(label, top: lastView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            lastView = label
        }
        lastView.bottom(bottomAnchor)
    }
    
    override func updateIconView() {
        selectedButton.image = NSImage(systemSymbolName: video.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func showVideo(){
        videoPlayerView.player?.pause()
        MainViewController.instance.showVideo(video)
    }
    
    @objc func editVideo(){
        delegate?.editVideo(video)
    }
    
    @objc func selectionChanged(){
        video.selected = !video.selected
        updateIconView()
    }
    
}
