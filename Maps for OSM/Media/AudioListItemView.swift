/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol AudioListItemDelegate{
    func shareAudio(sender: AudioListItemView)
    func deleteAudio(sender: AudioListItemView)
}

class AudioListItemView : UIView{
    
    var audioData : AudioFile
    
    var delegate : AudioListItemDelegate? = nil
    
    init(data: AudioFile){
        
        self.audioData = data
        super.init(frame: .zero)
        
        let deleteButton = UIButton().asIconButton("xmark.circle")
        deleteButton.tintColor = UIColor.systemRed
        deleteButton.addTarget(self, action: #selector(deleteAudio), for: .touchDown)
        addSubviewWithAnchors(deleteButton, top: topAnchor, trailing: trailingAnchor, insets: flatInsets)
        
        let shareButton = UIButton().asIconButton("square.and.arrow.up", color: .systemBlue)
        shareButton.addTarget(self, action: #selector(shareAudio), for: .touchDown)
        addSubviewWithAnchors(shareButton, top: topAnchor, trailing: deleteButton.leadingAnchor, insets: flatInsets)
        
        let audioView = AudioPlayerView()
        audioView.setRoundedBorders()
        addSubviewWithAnchors(audioView, top: shareButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
        audioView.url = audioData.fileURL
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func shareAudio(){
        delegate?.shareAudio(sender: self)
    }
    
    @objc func deleteAudio(){
        delegate?.deleteAudio(sender: self)
    }
    
}
