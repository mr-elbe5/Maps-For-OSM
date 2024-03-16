/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol VideoListItemDelegate{
    func viewVideo(sender: VideoListItemView)
    func deleteVideo(sender: VideoListItemView)
}

class VideoListItemView : UIView{
    
    var videoData : VideoFile
    
    var delegate : VideoListItemDelegate? = nil
    
    init(data: VideoFile){
        
        self.videoData = data
        super.init(frame: .zero)
        
        let buttonContainer = UIView()
        buttonContainer.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        buttonContainer.setRoundedBorders(radius: 5)
        
        let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
        viewButton.addAction(UIAction(){ action in
            self.delegate?.viewVideo(sender: self)
        }, for: .touchDown)
        buttonContainer.addSubviewWithAnchors(viewButton, top: buttonContainer.topAnchor, leading: buttonContainer.leadingAnchor, bottom: buttonContainer.bottomAnchor, insets: halfFlatInsets)
        
        let deleteButton = UIButton().asIconButton("xmark.circle", color: .systemRed)
        deleteButton.addAction(UIAction(){ action in
            self.delegate?.deleteVideo(sender: self)
        }, for: .touchDown)
        buttonContainer.addSubviewWithAnchors(deleteButton, top: buttonContainer.topAnchor, leading: viewButton.trailingAnchor, trailing: buttonContainer.trailingAnchor, bottom: buttonContainer.bottomAnchor, insets: halfFlatInsets)
        
        let videoView = VideoPlayerView()
        videoView.setRoundedBorders()
        addSubviewWithAnchors(videoView, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
        videoView.url = videoData.fileURL
        videoView.setAspectRatioConstraint()
        
        if !videoData.title.isEmpty{
            let titleView = UILabel(text: videoData.title)
            titleView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            addSubviewWithAnchors(titleView, top: videoView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        }
        else{
            videoView.bottom(bottomAnchor)
        }
        
        addSubviewWithAnchors(buttonContainer, top: topAnchor, trailing: trailingAnchor, insets: defaultInsets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
