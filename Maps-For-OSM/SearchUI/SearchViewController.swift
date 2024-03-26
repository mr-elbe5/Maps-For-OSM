/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

protocol SearchDelegate{
    func getCurrentRegion() -> CoordinateRegion
    func showSearchResult(coordinate: CLLocationCoordinate2D, mapRect: MapRect?)
}

//todo: extend search

class SearchViewController: PopupTableViewController{
    
    var searchField = UITextField()
    
    var delegate : SearchDelegate? = nil
    
    var locations = Array<NominatimLocation>()
    
    override func loadView() {
        title = "searchPlace".localize()
        createSubheaderView()
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.CELL_IDENT)
    }
    
    override func setupSubheaderView(subheaderView: UIView){
        searchField.placeholder = "searchPlaceholder".localize()
        searchField.borderStyle = .roundedRect
        searchField.text = AppState.shared.lastSearch
        subheaderView.addSubviewWithAnchors(searchField, top: subheaderView.topAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, insets: defaultInsets)
        
        let searchButton = UIButton()
        searchButton.setTitle("search".localize(), for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
        searchButton.addAction(UIAction(){ action in
            self.search()
        }, for: .touchDown)
        subheaderView.addSubviewWithAnchors(searchButton, top: searchField.bottomAnchor, bottom: subheaderView.bottomAnchor, insets: doubleInsets)
        .centerX(subheaderView.centerXAnchor)
    }
    
    func search(){
        if let text = searchField.text, !text.isEmpty{
            AppState.shared.lastSearch = text
            AppState.shared.save()
            let searchQuery = SearchQuery(searchString: text)
            searchQuery.search(){ (locations: Array<NominatimLocation>) in
                self.locations = locations
                DispatchQueue.main.async{
                    self.tableView.reloadData()
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
        self.dismiss(animated: false){
            self.delegate?.showSearchResult(coordinate: location.coordidate, mapRect: location.mapRect)
        }
    }
    
}

