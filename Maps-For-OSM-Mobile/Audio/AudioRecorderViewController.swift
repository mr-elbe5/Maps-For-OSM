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

class AudioRecorderViewController : NavScrollViewController, AVAudioRecorderDelegate{
    
    var audioRecorder = AudioRecorderView()
    var commentField = UITextField()
    var saveButton = UIButton()
    
    var delegate: AudioCaptureDelegate? = nil
    
    override func loadView() {
        title = "audioRecording".localize()
        super.loadView()
        setupKeyboard()
    }
    
    override func loadScrollableSubviews() {
        audioRecorder.setupView()
        audioRecorder.backgroundColor = .black
        audioRecorder.delegate = self
        contentView.addSubviewWithAnchors(audioRecorder, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        commentField.setDefaults(placeholder: "comment".localize())
        commentField.setKeyboardToolbar(doneTitle: "done".localize())
        contentView.addSubviewWithAnchors(commentField, top: audioRecorder.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        saveButton.asTextButton("save".localize()).withTextColor(color: .systemBlue)
        saveButton.setTitleColor(.systemGray, for: .disabled)
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: commentField.bottomAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
            .centerX(contentView.centerXAnchor)
        saveButton.isEnabled = false
    }
    
    func save(){
        let audioFile = AudioItem()
        audioFile.comment = commentField.text?.trim() ?? ""
        audioFile.time = (audioRecorder.currentTime*100).rounded() / 100
        //Log.debug("AudioRecorderViewController saving url \(audioFile.fileURL)")
        if FileManager.default.copyFile(fromURL: audioRecorder.tmpFileURL, toURL: FileManager.mediaDirURL.appendingPathComponent(audioFile.fileName)){
            audioRecorder.cleanup()
            self.close()
            self.delegate?.audioCaptured(audio: audioFile)
        }
        
    }
    
}

extension AudioRecorderViewController: AudioRecorderDelegate{
    
    func recordingFinished() {
        saveButton.isEnabled = true
    }
    
}
