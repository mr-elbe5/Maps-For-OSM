/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

protocol SearchDelegate{
    func showSearchResult(coordinate: CLLocationCoordinate2D, region: CoordinateRegion?)
}

class SearchViewController: PopupScrollViewController{
    
    var searchField = LabeledTextField()
    var resultView = UIStackView()
    
    var delegate : SearchDelegate? = nil
    
    override func loadView() {
        title = "search".localize()
        super.loadView()
        
        searchField.setupView(labelText: "searchField".localize(), text: "", isHorizontal: false)
        contentView.addSubviewWithAnchors(searchField, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let searchButton = UIButton()
        searchButton.setTitle("search".localize(), for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
        searchButton.addTarget(self, action: #selector(search), for: .touchDown)
        contentView.addSubviewWithAnchors(searchButton, top: searchField.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        contentView.addSubviewWithAnchors(resultView, top: searchButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
        resultView.setupVertical()
        
    }
    
    @objc func search(){
        resultView.removeAllArrangedSubviews()
        if !searchField.text.isEmpty{
            Nominatim.getLocation(of: searchField.text){ (locations: Array<NominatimLocation>) in
                if !locations.isEmpty{
                    DispatchQueue.main.async {
                        for loc in locations{
                            let btn = ResultButton()
                            btn.location = loc
                            btn.setTitle(loc.name, for: .normal)
                            btn.setTitleColor(.black, for: .normal)
                            btn.addTarget(self, action: #selector(self.showResult), for: .touchDown)
                            self.resultView.addArrangedSubview(btn)
                        }
                    }
                }
            }
        }
    }
    
    @objc func showResult(sender: AnyObject){
        if let btn = sender as? ResultButton, let location = btn.location{
            delegate?.showSearchResult(coordinate: location.coordidate, region: location.region)
            self.dismiss(animated: false)
        }
    }
    
}

class ResultButton : UIButton{
    
    var location: NominatimLocation? = nil
    
}
    

