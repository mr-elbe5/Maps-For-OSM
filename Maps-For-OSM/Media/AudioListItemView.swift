/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol AudioListItemDelegate{
    func deleteAudio(sender: AudioListItemView)
}

class AudioListItemView : UIView{
    
    var audioData : AudioFile
    
    var delegate : AudioListItemDelegate? = nil
    
    init(data: AudioFile){
        
        self.audioData = data
        super.init(frame: .zero)
        
        let deleteButton = UIButton().asIconButton("xmark.circle", color: .systemRed)
        deleteButton.addTarget(self, action: #selector(deleteAudio), for: .touchDown)
        addSubviewWithAnchors(deleteButton, top: topAnchor, trailing: trailingAnchor, insets: defaultInsets)
        
        let audioView = AudioPlayerView()
        audioView.setupView()
        addSubviewWithAnchors(audioView, top: deleteButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: UIEdgeInsets(top: 1, left: defaultInset, bottom: 0, right: defaultInset))
        
        if !audioData.title.isEmpty{
            let titleView = UILabel(text: audioData.title)
            titleView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            addSubviewWithAnchors(titleView, top: audioView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        }
        else{
            audioView.bottom(bottomAnchor)
        }
        
        audioView.url = audioData.fileURL
        audioView.enablePlayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deleteAudio(){
        delegate?.deleteAudio(sender: self)
    }
    
}

