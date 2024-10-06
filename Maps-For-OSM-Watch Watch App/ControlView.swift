//
//  ContentView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

struct ControlView: View {
    
    @State var phoneMessaging = PhoneMessaging()
    
    var body: some View {
        ScrollView{
            VStack {
                Button("Request Info") {
                    phoneMessaging.requestInfo()
                }
                ForEach(phoneMessaging.messages, id: \.self) { message in
                    Text(message)
                }
            }
        }
    }
    
}

#Preview {
    ControlView()
}
