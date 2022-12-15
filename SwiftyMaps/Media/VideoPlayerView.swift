/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    var player : AVPlayer
    var playerLayer : AVPlayerLayer
    var aspectRatio : CGFloat = 1
    
    var playButton = UIButton()
    
    var url : URL? = nil{
        didSet{
            if let url = url{
                let asset = AVURLAsset(url: url)
                debug("VideoPlayerView playing from url \(url)")
                if let file = FileController.readFile(url: url){
                    debug("VideoPlayerView file size is \(file.count)")
                }
                debug("track count = \(asset.tracks.count)")
                if let track = asset.tracks(withMediaType: AVMediaType.video).first{
                    let size = track.naturalSize.applying(track.preferredTransform)
                    self.aspectRatio = abs(size.width / size.height)
                }
                let item = AVPlayerItem(asset: asset)
                player.replaceCurrentItem(with: item)
                layoutSubviews()
            }
        }
    }
    
    override init(frame: CGRect) {
        self.player = AVPlayer()
        self.playerLayer = AVPlayerLayer(player: player)
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.needsDisplayOnBoundsChange = true
        self.layer.addSublayer(playerLayer)
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = UIColor.white
        playButton.addTarget(self, action: #selector(togglePlay), for: .touchDown)
        addSubviewWithAnchors(playButton, bottom: bottomAnchor, insets: defaultInsets)
            .centerX(centerXAnchor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer.frame = self.bounds
    }
    
    @objc func togglePlay(){
        if player.rate == 0{
            player.rate = 1
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        else{
            player.rate = 0
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
            player.rate = 0
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size.height == UIView.noIntrinsicMetric {
            size.height = size.width / aspectRatio
        }
        return size
    }
    
    func setAspectRatioConstraint() {
        let c = NSLayoutConstraint(item: self, attribute: .width,
                                   relatedBy: .equal,
                                   toItem: self, attribute: .height,
                                   multiplier: aspectRatio, constant: 0)
        c.priority = UILayoutPriority(900)
        self.addConstraint(c)
    }
    
}

