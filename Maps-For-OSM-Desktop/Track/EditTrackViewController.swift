/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import E5Data


class EditTrackViewController: ModalViewController {
    
    var startSize = CGSize(width: 1000, height: 800)
    
    var track: Track
    var newTrack = Track()
    
    var menuView: EditTrackMenuView
    var mapView: EditTrackMapView
    var trackpointDetailView: EditTrackpointDetailView
    var nameEditField = NSTextField()
    var minDistanceField = NSTextField()
    
    init(track: Track){
        self.track = track
        for tp in track.trackpoints{
            newTrack.trackpoints.append(Trackpoint(coordinate: tp.coordinate, altitude: tp.altitude, timestamp: tp.timestamp))
        }
        menuView = EditTrackMenuView()
        mapView = EditTrackMapView(track: newTrack)
        trackpointDetailView = EditTrackpointDetailView()
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: startSize)
        menuView.setupView()
        menuView.delegate = self
        view.addSubviewWithAnchors(menuView, top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        
        view.addSubviewWithAnchors(mapView, top: menuView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        
        trackpointDetailView.setupView()
        view.addSubviewWithAnchors(trackpointDetailView, top: mapView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        
        nameEditField.asEditableField(text: track.name)
        view.addSubviewWithAnchors(nameEditField, top: trackpointDetailView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        mapView.delegate = self
        let hintLabel = NSTextField(wrappingLabelWithString: "trackEditorHint".localize())
        view.addSubviewWithAnchors(hintLabel, top: nameEditField.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        let simplifyView = NSView()
        view.addSubviewWithAnchors(simplifyView, top: hintLabel.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        let simplifyLabel = NSTextField(labelWithString: "simplifyByDistance".localize())
        simplifyView.addSubviewWithAnchors(simplifyLabel, top: simplifyView.topAnchor, leading: simplifyView.leadingAnchor, bottom: simplifyView.bottomAnchor, insets: defaultInsets)
        simplifyView.addSubviewWithAnchors(minDistanceField, top: simplifyView.topAnchor, leading: simplifyLabel.trailingAnchor, bottom: simplifyView.bottomAnchor, insets: defaultInsets)
            .width(100)
        let simplifyButton = NSButton(title: "start".localize(), target: self, action: #selector(simplify))
        simplifyView.addSubviewWithAnchors(simplifyButton, top: simplifyView.topAnchor, leading: minDistanceField.trailingAnchor, bottom: simplifyView.bottomAnchor, insets: defaultInsets)
        let saveButton = NSButton(title: "save".localize(), target: self, action: #selector(save))
        view.addSubviewWithAnchors(saveButton, top: simplifyView.bottomAnchor, bottom: view.bottomAnchor, insets: defaultInsets)
            .centerX(view.centerXAnchor)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(nil)
    }
    
    func updateTrackpointDetailView(){
        var trackpoint: Trackpoint? = nil
        for tp in newTrack.trackpoints{
            if tp.selected{
                if trackpoint == nil{
                    trackpoint = tp
                }
                else{
                    trackpoint = nil
                    break
                }
            }
        }
        trackpointDetailView.setTrackPoint(trackpoint)
    }
    
    @objc func simplify(){
        let dist = Double(minDistanceField.stringValue)
        if let dist = dist, dist > 0{
            newTrack.setMinimalTrackpointDistances(minDistance: dist)
            mapView.trackpointsChanged()
        }
    }
    
    @objc func save(){
        track.name = nameEditField.stringValue
        track.setTrackpoints(newTrack.trackpoints)
        track.trackpointsChanged()
        responseCode = .OK
        view.window?.close()
    }
    
}

extension EditTrackViewController: EditTrackMenuDelegate{
    
    func toggleSelectAllTrackpoints() {
        if newTrack.trackpoints.allSelected{
            newTrack.trackpoints.deselectAll()
        }
        else{
            newTrack.trackpoints.selectAll()
        }
        for sv in mapView.subviews{
            if let marker = sv as? TrackpointMarker{
                marker.needsDisplay = true
            }
        }
        updateTrackpointDetailView()
    }
    
    func deleteSelectedTrackpoints() {
        var list = TrackpointList()
        for i in 0..<newTrack.trackpoints.count{
            let tp = newTrack.trackpoints[i]
            if tp.selected{
                list.append(tp)
            }
        }
        if list.isEmpty{
            return
        }
        print("deleting \(list.count) trackpoints")
        newTrack.trackpoints.removeAll(where: { tp in
            list.contains(where: { tp1 in
                return tp.id == tp1.id
            })
        })
        newTrack.trackpointsChanged()
        mapView.trackpointsChanged()
        updateTrackpointDetailView()
    }
    
    func undoTrackChanges(){
        newTrack.trackpoints.removeAll()
        for tp in track.trackpoints{
            newTrack.trackpoints.append(Trackpoint(coordinate: tp.coordinate, altitude: tp.altitude, timestamp: tp.timestamp))
        }
        newTrack.trackpointsChanged()
        mapView.trackpointsChanged()
    }
    
}

extension EditTrackViewController: EditTrackMapDelegate{
    
    func trackpointChangedInMap(_ trackpoint: Trackpoint) {
        updateTrackpointDetailView()
    }
    
}
