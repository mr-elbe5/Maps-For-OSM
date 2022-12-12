/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol VideoListItemDelegate{
    func viewVideo(sender: VideoListItemView)
    func shareVideo(sender: VideoListItemView)
    func deleteVideo(sender: VideoListItemView)
}

class VideoListItemView : UIView{
    
    var videoData : VideoData
    
    var delegate : VideoListItemDelegate? = nil
    
    init(data: VideoData){
        
        self.videoData = data
        super.init(frame: .zero)
        
        let deleteButton = UIButton().asIconButton("xmark.circle")
        deleteButton.tintColor = UIColor.systemRed
        deleteButton.addTarget(self, action: #selector(deleteVideo), for: .touchDown)
        addSubviewWithAnchors(deleteButton, top: topAnchor, trailing: trailingAnchor, insets: flatInsets)
        
        let viewButton = UIButton().asIconButton("magnifyingglass", color: .systemBlue)
        viewButton.addTarget(self, action: #selector(viewVideo), for: .touchDown)
        addSubviewWithAnchors(viewButton, top: topAnchor, trailing: deleteButton.leadingAnchor, insets: flatInsets)
        
        let shareButton = UIButton().asIconButton("square.and.arrow.up", color: .systemBlue)
        shareButton.addTarget(self, action: #selector(shareVideo), for: .touchDown)
        addSubviewWithAnchors(shareButton, top: topAnchor, trailing: viewButton.leadingAnchor, insets: flatInsets)
        
        let videoView = VideoPlayerView()
        videoView.setRoundedBorders()
        addSubviewWithAnchors(videoView, top: shareButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
        videoView.url = videoData.fileURL
        videoView.setAspectRatioConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func viewVideo(){
        delegate?.viewVideo(sender: self)
    }
    
    @objc func shareVideo(){
        delegate?.shareVideo(sender: self)
    }
    
    @objc func deleteVideo(){
        delegate?.deleteVideo(sender: self)
    }
    
}
