/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class VersionUpdateController: UIViewController{
    
    let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        stackView.setAnchors(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        let topLabel = UILabel(header: "updatingVersion".localize())
        stackView.addArrangedSubview(topLabel)
        updateVersion(from: AppState.shared.version, to: AppState.currentVersion)
    }
    
    func updateVersion(from: Int, to: Int){
        addText("creating backup...")
        let fileName = "maps4osm_backup_version\(from).zip"
        if let _ = Backup.createBackupFile(name: fileName){
            addText("backup saved as \(fileName)")
        }
        addText("exporting media to photo library...")
            Backup.exportToPhotoLibrary(resultHandler: { result in
                self.addText("exported \(result) images and videos files")
                self.addText("Images and videos of this app will from now be stored in the photo library, album 'Maps for OSM'")
                self.addText("Audio files are not supported by the photo library. Previous recordings can be found in the backup file.")
            })
        }
        
    }
    
    func addText(_ text: String){
        let label = UILabel(text: text)
        label.textColor = .black
        stackView.addArrangedSubview(label)
    }
    
}
