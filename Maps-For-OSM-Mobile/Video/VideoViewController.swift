/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class VideoViewController: NavViewController {
    
    var videoURL : URL? = nil
    
    var contentView = UIView()
    var videoView = VideoPlayerView()
    var volumeView = VolumeSlider()
    
    override func loadSubviews(guide: UILayoutGuide) {
        view.addSubviewWithAnchors(contentView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0))
        contentView.backgroundColor = .black
        
        if let url = videoURL{
            videoView.url = url
            contentView.addSubviewWithAnchors(videoView, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor)
            videoView.setAspectRatioConstraint()
            
            volumeView.addAction(UIAction(){ action in
                self.videoView.player.volume = self.volumeView.value
            }, for: .valueChanged)
            view.addSubviewWithAnchors(volumeView, top: videoView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
                .height(25)
        }
    }
    
}
