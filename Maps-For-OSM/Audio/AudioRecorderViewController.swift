/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation

protocol AudioCaptureDelegate{
    func audioCaptured(audio: AudioItem)
}

class AudioRecorderViewController : PopupScrollViewController, AVAudioRecorderDelegate{
    
    var audioRecorder = AudioRecorderView()
    var titleField = UITextField()
    var saveButton = UIButton()
    
    var delegate: AudioCaptureDelegate? = nil
    
    override init(){
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        scrollView.backgroundColor = .black
        
        audioRecorder.setupView()
        audioRecorder.delegate = self
        contentView.addSubviewWithAnchors(audioRecorder, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        titleField.setDefaults(placeholder: "comment".localize())
        titleField.setKeyboardToolbar(doneTitle: "done".localize())
        contentView.addSubviewWithAnchors(titleField, top: audioRecorder.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        saveButton.asTextButton("save".localize(), color: .white)
        saveButton.setTitleColor(.lightGray, for: .disabled)
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: titleField.bottomAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
            .centerX(contentView.centerXAnchor)
        saveButton.isEnabled = false
        setupKeyboard()
    }
    
    func save(){
        let audioFile = AudioItem()
        audioFile.title = titleField.text?.trim() ?? ""
        audioFile.time = (audioRecorder.currentTime*100).rounded() / 100
        //Log.debug("AudioRecorderViewController saving url \(audioFile.fileURL)")
        if FileController.copyFile(fromURL: audioRecorder.tmpFileURL, toURL: FileController.getURL(dirURL: AppURLs.mediaDirURL,fileName: audioFile.fileName)){
            audioRecorder.cleanup()
            self.dismiss(animated: true){
                self.delegate?.audioCaptured(audio: audioFile)
            }
        }
        
    }
    
}

extension AudioRecorderViewController: AudioRecorderDelegate{
    
    func recordingFinished() {
        saveButton.isEnabled = true
    }
    
}
