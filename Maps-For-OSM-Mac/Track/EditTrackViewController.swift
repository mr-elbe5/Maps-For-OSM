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
    
    var nameEditField = NSTextField()
    var splitView: SplitView
    var mapView: EditTrackMapView
    var listView: EditTrackListView
    var minDistanceField = NSTextField()
    
    init(track: Track){
        self.track = track
        for tp in track.trackpoints{
            newTrack.trackpoints.append(Trackpoint(coordinate: tp.coordinate, altitude: tp.altitude, timestamp: tp.timestamp))
        }
        mapView = EditTrackMapView(track: newTrack)
        listView = EditTrackListView(track: newTrack)
        splitView = SplitView(mainView: mapView, sideView: listView)
        splitView.minSideWidth = 200
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: startSize)
        nameEditField.asEditableField(text: track.name)
        view.addSubviewWithAnchors(nameEditField, top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        splitView.setupView()
        mapView.delegate = self
        listView.setupView()
        listView.delegate = self
        view.addSubviewWithAnchors(splitView, top: nameEditField.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        let hintLabel = NSTextField(wrappingLabelWithString: "trackEditorHint".localize())
        view.addSubviewWithAnchors(hintLabel, top: splitView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
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
        splitView.openSideView()
    }
    
    @objc func simplify(){
        let dist = Double(minDistanceField.stringValue)
        if let dist = dist, dist > 0{
            newTrack.setMinimalTrackpointDistances(minDistance: dist)
            mapView.trackpointsChanged()
            listView.trackpointsChanged()
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

extension EditTrackViewController: EditTrackListDelegate{
    
    func trackpointChangedInList(_ trackpoint: Trackpoint) {
        mapView.trackpointChangedInList(trackpoint)
    }
    
    func trackpointsChanged() {
        mapView.trackpointsChanged()
    }
    
}

extension EditTrackViewController: EditTrackMapDelegate{
    
    func trackpointChangedInMap(_ trackpoint: Trackpoint) {
        listView.trackpointChangedInMap(trackpoint)
    }
    
}
