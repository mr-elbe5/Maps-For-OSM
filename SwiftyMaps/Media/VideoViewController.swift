/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class VideoViewController: PopupViewController {
    
    var videoURL : URL? = nil
    
    var videoView = VideoPlayerView()
    var volumeView = VolumeSlider()
    
    override func loadView() {
        super.loadView()
        contentView.backgroundColor = .black
        
        if let url = videoURL{
            videoView.url = url
            contentView.addSubviewWithAnchors(videoView, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor)
            videoView.setAspectRatioConstraint()
            
            volumeView.addTarget(self, action: #selector(volumeChanged), for: .valueChanged)
            view.addSubviewWithAnchors(volumeView, top: videoView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
                .height(25)
        }
    }
    
    @objc func volumeChanged(){
        videoView.player.volume = volumeView.value
    }
    
}
