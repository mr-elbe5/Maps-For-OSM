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
        if let url = videoURL{
            videoView.url = url
            view.addSubviewWithAnchors(videoView, top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
            volumeView.addTarget(self, action: #selector(volumeChanged), for: .valueChanged)
            view.addSubviewWithAnchors(volumeView, top: videoView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor, insets: defaultInsets)
                .height(25)
            videoView.setAspectRatioConstraint()
        }
    }
    
    @objc func volumeChanged(){
        videoView.player.volume = volumeView.value
    }
    
}
