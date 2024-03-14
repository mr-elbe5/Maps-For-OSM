/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol MainMenuDelegate: MapPositionDelegate{
    
    func refreshMap()
    func openPreloadTiles()
    func changeTileSource()
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
    
    func openCamera(at coordinate: CLLocationCoordinate2D)
    
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
        crossControl.addAction(UIAction(){ action in
            AppState.shared.showCross = !AppState.shared.showCross
            self.delegate?.updateCross()
        }, for: .touchDown)
        
        let focusUserLocationControl = UIButton().asIconButton("record.circle")
        stackView.addArrangedSubview(focusUserLocationControl)
        focusUserLocationControl.addAction(UIAction(){ action in
            self.delegate?.focusUserLocation()
        }, for: .touchDown)
        
        let cameraControl = UIButton().asIconButton("camera")
        stackView.addArrangedSubview(cameraControl)
        cameraControl.addAction(UIAction(){ action in
            if let coordinate = LocationService.shared.location?.coordinate{
                self.delegate?.openCamera(at: coordinate)
            }
        }, for: .touchDown)
        
        let searchControl = UIButton().asIconButton("magnifyingglass")
        stackView.addArrangedSubview(searchControl)
        searchControl.addAction(UIAction(){ action in
            self.delegate?.openSearch()
        }, for: .touchDown)
        
        let exportControl = UIButton().asIconButton("square.and.arrow.up")
        stackView.addArrangedSubview(exportControl)
        exportControl.addAction(UIAction(){ action in
            self.delegate?.openExport()
        }, for: .touchDown)
        
        let preferencesControl = UIButton().asIconButton("gearshape")
        stackView.addArrangedSubview(preferencesControl)
        preferencesControl.addAction(UIAction(){ action in
            self.delegate?.openPreferences()
        }, for: .touchDown)
        
        let infoControl = UIButton().asIconButton("info.circle")
        stackView.addArrangedSubview(infoControl)
        infoControl.addAction(UIAction(){ action in
            self.delegate?.openInfo()
        }, for: .touchDown)
        
    }
    
    func getMapMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "refreshMap".localize(), image: UIImage(systemName: "arrow.clockwise")){ action in
            self.delegate?.refreshMap()
        })
        actions.append(UIAction(title: "preloadTiles".localize(), image: UIImage(systemName: "square.and.arrow.down")){ action in
            self.delegate?.openPreloadTiles()
        })
        actions.append(UIAction(title: "changeTileSource".localize(), image: UIImage(systemName: "map")){ action in
            self.delegate?.changeTileSource()
        })
        actions.append(UIAction(title: "deleteAllTiles".localize(), image: UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)){ action in
            self.delegate?.deleteAllTiles()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func getLocationMenu() -> UIMenu{
        var actions = Array<UIAction>()
        if AppState.shared.showLocations{
            actions.append(UIAction(title: "hidePlaces".localize(), image: UIImage(systemName: "mappin.slash")){ action in
                self.delegate?.showLocations(false)
                self.updateLocationMenu()
            })
        }
        else{
            actions.append(UIAction(title: "showPlaces".localize(), image: UIImage(systemName: "mappin")){ action in
                self.delegate?.showLocations(true)
                self.updateLocationMenu()
                
            })
        }
        actions.append(UIAction(title: "showPlaceList".localize(), image: UIImage(systemName: "list.bullet")){ action in
            self.delegate?.openLocationList()
        })
        actions.append(UIAction(title: "deleteAllPlaces".localize(), image: UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)){ action in
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
    
    func updateLocationMenu(){
        self.locationMenuControl.menu = self.getLocationMenu()
    }
    
    func updateTrackMenu(){
        self.trackMenuControl.menu = self.getTrackingMenu()
    }
    
    
    
}






