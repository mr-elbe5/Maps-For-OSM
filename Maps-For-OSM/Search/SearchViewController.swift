/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class SearchViewController: PopupScrollViewController{
    
    var searchField = UITextField()
    var resultView = UIStackView()
    
    override func loadView() {
        title = "searchPlace".localize()
        super.loadView()
        
        searchField.placeholder = "searchPlaceholder".localize()
        searchField.borderStyle = .roundedRect
        contentView.addSubviewWithAnchors(searchField, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let searchButton = UIButton()
        searchButton.setTitle("search".localize(), for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
        searchButton.addAction(UIAction(){ action in
            self.search()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(searchButton, top: searchField.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        contentView.addSubviewWithAnchors(resultView, top: searchButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
        resultView.setupVertical()
        
    }
    
    func search(){
        resultView.removeAllArrangedSubviews()
        if let text = searchField.text, !text.isEmpty{
            Nominatim.getLocation(of: text){ (locations: Array<NominatimLocation>) in
                if !locations.isEmpty{
                    DispatchQueue.main.async {
                        for loc in locations{
                            let btn = UIButton()
                            btn.setTitle(loc.name, for: .normal)
                            btn.setTitleColor(.black, for: .normal)
                            btn.addAction(UIAction(){ action in
                                self.showResult(location: loc)
                            }, for: .touchDown)
                            self.resultView.addArrangedSubview(btn)
                        }
                    }
                }
            }
        }
    }
    
    func showResult(location: NominatimLocation){
        self.dismiss(animated: false){
            mainViewController.showSearchResult(coordinate: location.coordidate, mapRect: location.mapRect)
        }
    }
    
}

