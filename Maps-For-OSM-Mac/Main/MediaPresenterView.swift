/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import AVKit
import E5MapData

class MediaPresenterView: NSView {
    
    var items = Array<LocatedItem>()
    var currentIdx = 0
    
    var imageView = NSImageView()
    var videoView = AVPlayerView()
    var nextButton: NSButton!
    var previousButton: NSButton!
    
    override func setupView(){
        imageView.autoresizingMask = [.height, .width]
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubviewFilling(imageView)
        addSubviewFilling(videoView)
        videoView.isHidden = true
        
        let config = NSImage.SymbolConfiguration(textStyle: .headline, scale: .large)
        nextButton = NSButton(image: NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)!
            .withSymbolConfiguration(config)!, target: self, action: #selector(nextImage))
        nextButton.bezelStyle = .inline
        nextButton.keyEquivalent = NSString(characters: [unichar(NSRightArrowFunctionKey)], length: 1) as String
        addSubview(nextButton)
        nextButton.setAnchors().trailing(trailingAnchor, inset: 20)
            .centerY(centerYAnchor)
        previousButton = NSButton(image: NSImage(systemSymbolName: "chevron.left", accessibilityDescription: nil)!
            .withSymbolConfiguration(config)!, target: self, action: #selector(previousImage))
        previousButton.bezelStyle = .inline
        previousButton.keyEquivalent = NSString(characters: [unichar(NSLeftArrowFunctionKey)], length: 1) as String
        addSubview(previousButton)
        previousButton.setAnchors().leading(leadingAnchor, inset: 20)
            .centerY(centerYAnchor)
        checkButtons()
    }
    
    func show(_ flag: Bool) {
        isHidden = !flag
    }
    
    func updateMedia(){
        setItemView(item: items.first)
        currentIdx = 0
        checkButtons()
    }
    
    func setMedia(_ items:Array<LocatedItem>){
        self.items = items
        updateMedia()
    }
    
    func setMediaItem(item: LocatedItem){
        var arr = Array<LocatedItem>()
        arr.append(item)
        setMedia(arr)
    }
    
    func setItemView(item: LocatedItem?){
        resetViews()
        if let item = item{
            switch item.type{
            case .image:
                if let image = item as? Image, let img = image.getImage(){
                    imageView.isHidden = false
                    imageView.image = img
                }
            case .video:
                if let video = item as? Video{
                    videoView.isHidden = false
                    videoView.player = AVPlayer(url: video.fileURL)
                }
            default:
                break
            }
        }
    }
    
    func resetViews(){
        imageView.image = nil
        imageView.isHidden = true
        videoView.player?.pause()
        videoView.player = nil
        videoView.isHidden = true
    }
    
    func reset(){
        resetViews()
        videoView.isHidden = true
        currentIdx = 0
        checkButtons()
    }
    
    @objc func nextImage(){
        if currentIdx < items.count - 1{
            currentIdx += 1
            setItemView(item: items[currentIdx])
            checkButtons()
        }
    }
    
    @objc func previousImage(){
        if currentIdx > 0{
            currentIdx -= 1
            setItemView(item: items[currentIdx])
            checkButtons()
        }
    }
    
    private func checkButtons(){
        previousButton.isHidden = currentIdx <= 0
        nextButton.isHidden = currentIdx >= items.count - 1
    }
    
}




