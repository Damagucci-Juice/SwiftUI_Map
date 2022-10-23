//
//  MapView.swift
//  KlipApp
//
//  Created by 박진섭 on 2022/10/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var viewModel = MapViewModel()
    @State var currentLocationDescription = "no Info"
    @State var startingPoint: MKCoordinateRegion = .init()

    // TODO: Tracking mode 및 Alert 처리.
    @State private var trackingMode: MapUserTrackingMode = .follow
    @State private var showAlert: Bool = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Map
            Map(coordinateRegion: $startingPoint,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: $trackingMode
            )

            // Description
            HStack(alignment: .top) {
                Text("\(currentLocationDescription)")
                    .foregroundColor(Color.black)
                    .background(Color.white)
                    .onChange(of: viewModel.currentLocation) { newValue in
                        let description = newValue?.getDescription()
                        self.currentLocationDescription = description ?? "No Info"
                    }

                Spacer()

                // 위치 추적 버튼
                Button {
                    if trackingMode == .none {
                        self.trackingMode = .follow
                    } else {
                        self.trackingMode = .none
                    }
                } label: {
                    Image(systemName: "location.square")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                        .background(Color.white)
                }
            }
        }
        .onAppear {
            viewModel.startUpdatingLocation()
            // 뷰를 나갔다가 들어왔을때 위치를 못잡는 이슈 제거
            trackingMode = .follow
        }

        .onDisappear {
            viewModel.stopUpdatingLocation()
        }
    }
}
