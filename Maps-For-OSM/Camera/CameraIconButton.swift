import UIKit
import AVFoundation
import CoreLocation
import Photos

class CameraIconButton: UIButton{
    
    func setup(icon: String){
        setImage(UIImage(systemName: icon), for: .normal)
        configuration = UIButton.Configuration.borderless()
        configuration?.imagePadding = 0
        backgroundColor = .white
        setRoundedBorders()
        tintColor = .black
        scaleBy(0.7)
    }
    
}
