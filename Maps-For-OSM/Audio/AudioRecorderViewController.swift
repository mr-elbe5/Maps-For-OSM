/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import E5Data
import E5IOSUI
import E5MapData

protocol AudioCaptureDelegate{
    func audioCaptured(audio: Audio)
}

class AudioRecorderViewController : NavScrollViewController, AVAudioRecorderDelegate{
    
    var audioRecorder = AudioRecorderView()
    var titleField = UITextField()
    var saveButton = UIButton()
    
    var delegate: AudioCaptureDelegate? = nil
    
    override func loadView() {
        title = "audioRecording".localize()
        super.loadView()
        setBlackNavigation()
        scrollView.backgroundColor = .black
        setupKeyboard()
    }
    
    override func loadScrollableSubviews() {
        audioRecorder.setupView()
        audioRecorder.delegate = self
        contentView.addSubviewWithAnchors(audioRecorder, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        titleField.setDefaults(placeholder: "comment".localize())
        titleField.setKeyboardToolbar(doneTitle: "done".localize())
        contentView.addSubviewWithAnchors(titleField, top: audioRecorder.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        saveButton.asTextButton("save".localize()).withTextColor(color: .white)
        saveButton.setTitleColor(.lightGray, for: .disabled)
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: titleField.bottomAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
            .centerX(contentView.centerXAnchor)
        saveButton.isEnabled = false
    }
    
    func save(){
        let audioFile = Audio()
        audioFile.title = titleField.text?.trim() ?? ""
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
