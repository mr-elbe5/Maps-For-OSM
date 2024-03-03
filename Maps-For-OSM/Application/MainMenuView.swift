/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol MainMenuDelegate: MapPositionDelegate{
    
    func refreshMap()
    func openPreloadTiles()
    func deleteAllTiles()
    
    func showLocations(_ show: Bool)
    func openLocationList()
    func deleteAllLocations()
    
    func startRecording()
    func pauseRecording()
    func resumeRecording()
    func cancelRecording()
    func saveRecordedTrack()
    func hideTrack()
    func openTrackList()
    func deleteAllTracks()
    
    func updateCross()
    func focusUserLocation()
    
    func openSearch()
    
    func openExport()
    
    func openPreferences()
    
    func openInfo()
    
}

class MainMenuView: UIView {
    
    //MainViewController
    var delegate : MainMenuDelegate? = nil
    
    var mapMenuControl = UIButton().asIconButton("map")
    var locationMenuControl = UIButton().asIconButton("mappin")
    var trackMenuControl = UIButton().asIconButton("figure.walk")
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubviewFilling(stackView, insets: defaultInsets)
        
        stackView.addArrangedSubview(mapMenuControl)
        mapMenuControl.menu = getMapMenu()
        mapMenuControl.showsMenuAsPrimaryAction = true
        
        stackView.addArrangedSubview(locationMenuControl)
        locationMenuControl.menu = getLocationMenu()
        locationMenuControl.showsMenuAsPrimaryAction = true
        
        stackView.addArrangedSubview(trackMenuControl)
        trackMenuControl.menu = getTrackingMenu()
        trackMenuControl.showsMenuAsPrimaryAction = true
        
        let crossControl = UIButton().asIconButton("plus.circle")
        stackView.addArrangedSubview(crossControl)
        crossControl.addTarget(self, action: #selector(toggleCross), for: .touchDown)
        
        let focusUserLocationControl = UIButton().asIconButton("record.circle")
        stackView.addArrangedSubview(focusUserLocationControl)
        focusUserLocationControl.addTarget(self, action: #selector(focusUserLocation), for: .touchDown)
        
        let cameraControl = UIButton().asIconButton("camera")
        stackView.addArrangedSubview(cameraControl)
        cameraControl.menu = getCameraMenu()
        cameraControl.showsMenuAsPrimaryAction = true
        
        let searchControl = UIButton().asIconButton("magnifyingglass")
        stackView.addArrangedSubview(searchControl)
        searchControl.addTarget(self, action: #selector(openSearch), for: .touchDown)
        
        let exportControl = UIButton().asIconButton("square.and.arrow.up")
        stackView.addArrangedSubview(exportControl)
        exportControl.addTarget(self, action: #selector(openExport), for: .touchDown)
        
        let preferencesControl = UIButton().asIconButton("gearshape")
        stackView.addArrangedSubview(preferencesControl)
        preferencesControl.addTarget(self, action: #selector(openPreferences), for: .touchDown)
        
        let infoControl = UIButton().asIconButton("info.circle")
        stackView.addArrangedSubview(infoControl)
        infoControl.addTarget(self, action: #selector(openInfo), for: .touchDown)
        
    }
    
    func getMapMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "refreshMap".localize(), image: UIImage(systemName: "arrow.clockwise")){ action in
            self.delegate?.refreshMap()
        })
        actions.append(UIAction(title: "preloadTiles".localize(), image: UIImage(systemName: "square.and.arrow.down")){ action in
            self.delegate?.openPreloadTiles()
        })
        actions.append(UIAction(title: "deleteAllTiles".localize(), image: UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)){ action in
            self.delegate?.deleteAllTiles()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func getLocationMenu() -> UIMenu{
        var actions = Array<UIAction>()
        if AppState.shared.showLocations{
            actions.append(UIAction(title: "hideLocations".localize(), image: UIImage(systemName: "mappin.slash")){ action in
                self.delegate?.showLocations(false)
                self.updateLocationMenu()
            })
        }
        else{
            actions.append(UIAction(title: "showLocations".localize(), image: UIImage(systemName: "mappin")){ action in
                self.delegate?.showLocations(true)
                self.updateLocationMenu()
                
            })
        }
        actions.append(UIAction(title: "showLocationList".localize(), image: UIImage(systemName: "list.bullet")){ action in
            self.delegate?.openLocationList()
        })
        actions.append(UIAction(title: "deleteAllLocations".localize(), image: UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)){ action in
            self.delegate?.deleteAllLocations()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func getTrackingMenu() -> UIMenu{
        var actions = Array<UIAction>()
        if TrackRecorder.track != nil{
            if TrackRecorder.isRecording{
                actions.append(UIAction(title: "pauseRecording".localize(), image: UIImage(systemName: "pause")){ action in
                    self.delegate?.pauseRecording()
                    self.updateTrackMenu()
                })
            }
            else{
                actions.append(UIAction(title: "resumeRecording".localize(), image: UIImage(systemName: "play")){ action in
                    self.delegate?.resumeRecording()
                    self.updateTrackMenu()
                })
            }
            actions.append(UIAction(title: "cancelRecording".localize(), image: UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)){ action in
                self.delegate?.cancelRecording()
                self.updateTrackMenu()
            })
            actions.append(UIAction(title: "saveRecordedTour".localize(), image: UIImage(systemName: "square.and.arrow.down")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)){ action in
                self.delegate?.saveRecordedTrack()
                self.updateTrackMenu()
            })
        }
        else{
            actions.append(UIAction(title: "startRecording".localize(), image: UIImage(systemName: "figure.walk")){ action in
                self.delegate?.startRecording()
                self.updateTrackMenu()
            })
            if TrackPool.visibleTrack != nil {
                actions.append(UIAction(title: "hideTrack".localize(), image: UIImage(systemName: "eye.slash")){ action in
                    self.delegate?.hideTrack()
                    self.updateTrackMenu()
                })
            }
            actions.append(UIAction(title: "showTrackList".localize(), image: UIImage(systemName: "list.bullet")){ action in
                self.delegate?.openTrackList()
            })
            actions.append(UIAction(title: "deleteAllTracks".localize(), image: UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)){ action in
                self.delegate?.deleteAllTracks()
            })
        }
        return UIMenu(title: "", children: actions)
    }
    
    func getCameraMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "openCamera".localize(), image: UIImage(systemName: "camera")){ action in
            self.delegate?.openCameraAtCurrentPosition()
        })
        actions.append(UIAction(title: "addAudio".localize(), image: UIImage(systemName: "mic")){ action in
            self.delegate?.addAudioAtCurrentPosition()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func updateLocationMenu(){
        self.locationMenuControl.menu = self.getLocationMenu()
    }
    
    func updateTrackMenu(){
        self.trackMenuControl.menu = self.getTrackingMenu()
    }
    
    @objc func toggleCross(){
        AppState.shared.showCross = !AppState.shared.showCross
        delegate?.updateCross()
    }
    
    @objc func focusUserLocation(){
        delegate?.focusUserLocation()
    }
    
    @objc func openInfo(){
        delegate?.openInfo()
    }
    
    @objc func openExport(){
        delegate?.openExport()
    }
    
    @objc func openPreferences(){
        delegate?.openPreferences()
    }
    
    @objc func openSearch(){
        delegate?.openSearch()
    }
    
}






