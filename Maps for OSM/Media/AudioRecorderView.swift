/*
 My Private Track
 App for creating a diary with entry based on time and map location using text, photos, audios and videos
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVFoundation

class AudioRecorderView : UIView, AVAudioRecorderDelegate{
    
    var audioRecorder: AVAudioRecorder? = nil
    var isRecording: Bool = false
    var currentTime: Double = 0.0
    
    var data : AudioData!
    
    var player = AudioPlayerView()
    var recordButton = CaptureButton()
    var timeLabel = UILabel()
    var progress = AudioProgressView()
    
    
    func setupView() {
        backgroundColor = .black
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        addSubview(timeLabel)
        progress.setupView()
        addSubview(progress)
        recordButton.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        addSubview(recordButton)
        self.recordButton.isEnabled = true
        player.setupView()
        player.backgroundColor = .systemBackground
        addSubview(player)
    }

    func layoutView(){
        timeLabel.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        progress.setAnchors(top: timeLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
        progress.layoutView()
        recordButton.setAnchors(top: progress.bottomAnchor, insets: defaultInsets)
            .centerX(centerXAnchor)
            .width(50)
            .height(50)
        player.setAnchors(top: recordButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        player.layoutView()
        player.disablePlayer()
        updateTime(time: 0.0)
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
        do{
            audioRecorder = try AVAudioRecorder(url: data.fileURL, settings: settings)
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
            player.url = data.fileURL
            player.enablePlayer()
            data.time = (self.currentTime*100).rounded() / 100
        } else {
            player.disablePlayer()
            player.url = nil
        }
        recordButton.buttonState = .normal
    }
    
    func updateTime(time: Double){
        timeLabel.text = String(format: "%.02f s", time)
    }
    
    func updateProgress(decibels: Float){
        progress.setProgress((min(max(-60.0, decibels),0) + 60.0) / 60.0)
    }
    
    @objc func toggleRecording() {
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
                        session.requestRecordPermission() { allowed in
                            isEnabled = true
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
        backgroundColor = .clear
        lowLabel.tintColor = .white
        addSubview(lowLabel)
        progress.progressTintColor = .systemRed
        progress.progress = 0.0
        addSubview(progress)
        loudLabel.tintColor = .white
        addSubview(loudLabel)
        
    }
    
    func layoutView(){
        lowLabel.setAnchors(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        loudLabel.setAnchors(top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        progress.setAnchors(top: topAnchor, leading: lowLabel.trailingAnchor, trailing: loudLabel.leadingAnchor, bottom: bottomAnchor, insets: defaultInsets)
    }
    
    func setProgress(_ value: Float){
        progress.setProgress(value, animated: true)
    }
    
}
