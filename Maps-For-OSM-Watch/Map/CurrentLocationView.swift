//
//  CurrentLocationView.swift
//  Maps For OSM Watch
//
//  Created by Michael Rönnau on 08.10.24.
//

import Foundation
import SwiftUI

struct CurrentLocationView: View {
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.blue, lineWidth: 2)
            Circle()
                .fill(Color(.blue))
                .frame(width: 8, height: 8)
        }
        .frame(width: 20, height: 20)
    }
    
}

#Preview {
    CurrentLocationView()
}
