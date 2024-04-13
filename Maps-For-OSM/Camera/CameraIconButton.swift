/*
 E5Cam
 Simple Camera
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

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
