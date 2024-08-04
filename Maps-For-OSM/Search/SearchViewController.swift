/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5IOSUI
import E5MapData

protocol SearchDelegate{
    func getCurrentRegion() -> CoordinateRegion
    func getCurrentCenter() -> CLLocationCoordinate2D
    func showSearchResult(coordinate: CLLocationCoordinate2D, mapRect: CGRect?)
}

class SearchViewController: NavTableViewController{
    
    var searchField = UITextField()
    var targetControl = UISegmentedControl()
    var regionControl = UISegmentedControl()
    var radiusSlider = RadiusSlider()
    
    var target: SearchQuery.SearchTarget = AppState.shared.searchTarget
    var region: SearchQuery.SearchRegion = AppState.shared.searchRegion
    
    var delegate : SearchDelegate? = nil
    
    var locations = Array<NominatimLocation>()
    
    override func loadView() {
        title = "searchLocation".localize()
        createSubheaderView()
        super.loadView()
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.CELL_IDENT)
    }
    
    override func setupSubheaderView(subheaderView: UIView){
        subheaderView.setRoundedEdges()
        searchField.placeholder = "searchPlaceholder".localize()
        searchField.borderStyle = .roundedRect
        searchField.text = AppState.shared.searchString
        subheaderView.addSubviewWithAnchors(searchField, top: subheaderView.topAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, insets: defaultInsets)
        
        targetControl.insertSegment(action: UIAction(){_ in
            self.target = .any
        }, at: 0, animated: false)
        targetControl.setTitle("anyTarget".localize(), forSegmentAt: 0)
        targetControl.insertSegment(action: UIAction(){_ in
            self.target = .city
        }, at: 1, animated: false)
        targetControl.setTitle("cityTarget".localize(), forSegmentAt: 1)
        targetControl.insertSegment(action: UIAction(){_ in
            self.target = .street
        }, at: 2, animated: false)
        targetControl.setTitle("streetTarget".localize(), forSegmentAt: 2)
        targetControl.insertSegment(action: UIAction(){_ in
            self.target = .poi
        }, at: 3, animated: false)
        targetControl.setTitle("poiTarget".localize(), forSegmentAt: 3)
        subheaderView.addSubviewWithAnchors(targetControl, top: searchField.bottomAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, insets: doubleInsets)
        targetControl.selectedSegmentIndex = AppState.shared.searchTarget.rawValue
        
        regionControl.insertSegment(action: UIAction(){_ in
            self.region = .unlimited
        }, at: 0, animated: false)
        regionControl.setTitle("unlimitedRegion".localize(), forSegmentAt: 0)
        regionControl.insertSegment(action: UIAction(){_ in
            self.region = .current
        }, at: 1, animated: false)
        regionControl.setTitle("currentRegion".localize(), forSegmentAt: 1)
        regionControl.insertSegment(action: UIAction(){_ in
            self.region = .radius
        }, at: 2, animated: false)
        regionControl.setTitle("radiusRegion".localize(), forSegmentAt: 2)
        subheaderView.addSubviewWithAnchors(regionControl, top: targetControl.bottomAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, insets: doubleInsets)
        regionControl.selectedSegmentIndex = AppState.shared.searchRegion.rawValue
        regionControl.addAction(UIAction(){ action in
            self.updateSlider()
        }, for: .valueChanged)
        
        radiusSlider.setup()
        radiusSlider.slider.value = Float(AppState.shared.searchRadius)
        subheaderView.addSubviewWithAnchors(radiusSlider, top: regionControl.bottomAnchor, insets: defaultInsets)
            .centerX(subheaderView.centerXAnchor).width(300)
        updateSlider()
        
        let searchButton = UIButton()
        searchButton.setTitle("search".localize(), for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
        searchButton.addAction(UIAction(){ action in
            self.search()
        }, for: .touchDown)
        subheaderView.addSubviewWithAnchors(searchButton, top: radiusSlider.bottomAnchor, bottom: subheaderView.bottomAnchor, insets: doubleInsets)
        .centerX(subheaderView.centerXAnchor)
    }
    
    func updateSlider(){
        radiusSlider.isHidden = self.region != .radius
    }
    
    func search(){
        if let text = searchField.text, !text.isEmpty{
            AppState.shared.searchString = text
            AppState.shared.searchTarget = SearchQuery.SearchTarget(rawValue: targetControl.selectedSegmentIndex)!
            AppState.shared.searchRegion = SearchQuery.SearchRegion(rawValue: regionControl.selectedSegmentIndex)!
            AppState.shared.searchRadius = Double(radiusSlider.slider.value)
            AppState.shared.save()
            let searchQuery = SearchQuery()
            switch AppState.shared.searchRegion{
            case .current:
                if let currentRegion = delegate?.getCurrentRegion(){
                    Log.debug("searching in current region \(currentRegion)")
                    searchQuery.coordinateRegion = currentRegion
                }
                else{
                    AppState.shared.searchRegion = .unlimited
                }
            case .radius:
                if let currentCenter = delegate?.getCurrentCenter(){
                    let coordinateRegion = currentCenter.coordinateRegion(radiusMeters: AppState.shared.searchRadius*1000)
                    Log.debug("searching in radius region \(coordinateRegion)")
                    searchQuery.coordinateRegion = coordinateRegion
                }
                else{
                    AppState.shared.searchRegion = .unlimited
                }
            default:
                break
            }
            searchQuery.search(){ (locations: Array<NominatimLocation>?) in
                if let locations = locations{
                    self.locations = locations
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
                else{
                    DispatchQueue.main.async{
                        self.showError("noValidSearch".localize())
                    }
                }
            }
        }
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = locations[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.CELL_IDENT, for: indexPath) as? SearchResultCell{
            cell.location = location
            cell.delegate = self
            cell.updateCell(isEditing: false)
            return cell
        }
        else{
            Log.error("no valid item/cell for serach result")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension SearchViewController: SearchResultCellDelegate{
    
    func showResult(location: NominatimLocation){
        self.close()
        self.delegate?.showSearchResult(coordinate: location.coordidate, mapRect: location.mapRect)
    }
    
}

class RadiusSlider : UIView{
    
    var slider = UISlider()
    
    func setup(){
        slider.minimumValue = 1.0
        slider.maximumValue = 100.0
        addSubviewWithAnchors(slider, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        let leftLabel = UILabel(text: "0km")
        addSubviewWithAnchors(leftLabel, top: slider.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor)
        let rightLabel = UILabel(text: "100km")
        addSubviewWithAnchors(rightLabel, top: slider.bottomAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
    
}

