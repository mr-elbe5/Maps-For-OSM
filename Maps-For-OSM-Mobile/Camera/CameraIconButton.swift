/*
 E5Cam
 Simple Camera
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import Photos
import E5IOSUI

open class CameraIconButton: UIButton{
    
    open func setup(icon: String){
        setImage(UIImage(systemName: icon), for: .normal)
        configuration = UIButton.Configuration.borderless()
        configuration?.imagePadding = 0
        backgroundColor = .white
        setRoundedBorders()
        tintColor = .black
        scaleBy(0.7)
    }
    
}
