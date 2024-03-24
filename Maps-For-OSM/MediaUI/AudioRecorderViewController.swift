/*
 My Private Track
 App for creating a diary with entry based on time and map location using text, photos, audios and videos
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVFoundation

protocol AudioCaptureDelegate{
    func audioCaptured(item: AudioItem)
}

class AudioRecorderViewController : PopupScrollViewController, AVAudioRecorderDelegate{
    
    var audioRecorder: AVAudioRecorder? = nil
    var isRecording: Bool = false
    var currentTime: Double = 0.0
    
    var player = AudioPlayerView()
    var recordButton = CaptureButton()
    var titleField = UITextField()
    var saveButton = UIButton()
    var timeLabel = UILabel()
    var progress = AudioProgressView()
    
    var tmpFileName = "tmpaudio.m4a"
    var tmpFileURL : URL
    
    var delegate: AudioCaptureDelegate? = nil
    
    override init(){
        tmpFileURL = FileController.temporaryURL.appendingPathComponent(tmpFileName)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        scrollView.backgroundColor = .black
        
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        contentView.addSubviewWithAnchors(timeLabel, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        contentView.addSubviewWithAnchors(progress, top: timeLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        progress.setupView()
        
        contentView.addSubviewWithAnchors(player, top: progress.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
            .setBackground(.black)
        player.setupView()
        player.disablePlayer()
        
        recordButton.addAction(UIAction(){ action in
            self.toggleRecording()
        }, for: .touchUpInside)
        contentView.addSubviewWithAnchors(recordButton, top: player.bottomAnchor, insets: defaultInsets)
            .centerX(contentView.centerXAnchor)
            .width(50)
            .height(50)
        recordButton.isEnabled = false
        
        titleField.setDefaults(placeholder: "comment".localize())
        titleField.setKeyboardToolbar(doneTitle: "done".localize())
        contentView.addSubviewWithAnchors(titleField, top: recordButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        saveButton.asTextButton("save".localize(), color: .white)
        saveButton.setTitleColor(.lightGray, for: .disabled)
        saveButton.addAction(UIAction(){ action in
            self.save()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: titleField.bottomAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
            .centerX(contentView.centerXAnchor)
        saveButton.isEnabled = false
        
        
        updateTime(time: 0.0)
        AVCaptureDevice.askAudioAuthorization(){ result in
            self.enableRecording()
        }
        setupKeyboard()
    }
    
    func enableRecording(){
        AudioSession.enableRecording(){result in
            switch result{
            case .success:
                DispatchQueue.main.async {
                    self.recordButton.isEnabled = true
                }
            default:
                break
            }
        }
    }
    
    func startRecording() {
        player.disablePlayer()
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVNumberOfChannelsKey: 1,
        ]
        //Log.debug("AudioRecorderViewController recording on url \(tmpFileURL)")
        do{
            audioRecorder = try AVAudioRecorder(url: tmpFileURL, settings: settings)
            if let recorder = audioRecorder{
                recorder.isMeteringEnabled = true
                recorder.delegate = self
                recorder.record()
                isRecording = true
                self.recordButton.buttonState = .recording
                DispatchQueue.global(qos: .userInitiated).async {
                    repeat{
                        recorder.updateMeters()
                        DispatchQueue.main.async {
                            self.currentTime = recorder.currentTime
                            self.updateTime(time: self.currentTime)
                            self.updateProgress(decibels: recorder.averagePower(forChannel: 0))
                        }
                        // 1/10s
                        usleep(100000)
                    } while self.isRecording
                }
            }
        }
        catch{
            recordButton.isEnabled = false
        }
    }
    
    func finishRecording(success: Bool) {
        isRecording = false
        audioRecorder?.stop()
        audioRecorder = nil
        if success {
            //Log.debug("AudioRecorderViewController playing on url \(tmpFileURL)")
            player.url = tmpFileURL
            player.enablePlayer()
        } else {
            player.disablePlayer()
            player.url = nil
        }
        recordButton.buttonState = .normal
        saveButton.isEnabled = true
    }
    
    func updateTime(time: Double){
        timeLabel.text = String(format: "%.02f s", time)
    }
    
    func updateProgress(decibels: Float){
        progress.setProgress((min(max(-60.0, decibels),0) + 60.0) / 60.0)
    }
    
    func toggleRecording() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: flag)
        }
    }
    
    func save(){
        let audioFile = AudioItem()
        audioFile.title = titleField.text?.trim() ?? ""
        audioFile.time = (currentTime*100).rounded() / 100
        //Log.debug("AudioRecorderViewController saving url \(audioFile.fileURL)")
        if FileController.copyFile(fromURL: tmpFileURL, toURL: FileController.getURL(dirURL: FileController.mediaDirURL,fileName: audioFile.fileName)){
            cleanup()
            self.dismiss(animated: true){
                self.delegate?.audioCaptured(item: audioFile)
            }
        }
        
    }
    
    func cleanup() {
        if FileManager.default.fileExists(atPath: tmpFileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: tmpFileURL.path)
            } catch let err{
                Log.error("AudioRecorderViewController Could not remove file at url: \(String(describing: tmpFileURL))", error: err)
            }
        }
    }
    
}

class AudioSession{
    
    static var isEnabled = false
    
    static func enableRecording(callback: @escaping (Result<Void, Error>) -> Void){
        if isEnabled{
            callback(.success(()))
        }
        else{
            AVCaptureDevice.askAudioAuthorization(){ result in
                switch result{
                case .success(()):
                    do {
                        let session = AVAudioSession.sharedInstance()
                        try session.setCategory(.playAndRecord, mode: .default)
                        try session.overrideOutputAudioPort(.speaker)
                        try session.setActive(true)
                        AVAudioApplication.requestRecordPermission{allowed in
                            isEnabled = allowed
                            callback(.success(()))
                        }
                    } catch {
                        callback(.failure(NSError()))
                    }
                    return
                case .failure:
                    callback(.failure(NSError()))
                    return
                }
            }
        }
    }
    
}

class AudioProgressView : UIView{
    
    var lowLabel = UIImageView(image: UIImage(systemName: "speaker"))
    var progress = UIProgressView()
    var loudLabel = UIImageView(image: UIImage(systemName: "speaker.3"))
    
    func setupView() {
        backgroundColor = .black
        lowLabel.tintColor = .white
        addSubviewWithAnchors(lowLabel, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        progress.progressTintColor = .systemRed
        progress.progress = 0.0
        addSubviewWithAnchors(progress, top: topAnchor, leading: lowLabel.trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        loudLabel.tintColor = .white
        addSubviewWithAnchors(loudLabel, top: topAnchor, leading: progress.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
    }
    
    func setProgress(_ value: Float){
        progress.setProgress(value, animated: true)
    }
    
}
