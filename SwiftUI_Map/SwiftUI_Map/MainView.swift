//
//  MainView.swift
//  SwiftUI_Map
//
//  Created by 박진섭 on 2022/10/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("Map!", destination: MapView())
            }
        }
    }
}
