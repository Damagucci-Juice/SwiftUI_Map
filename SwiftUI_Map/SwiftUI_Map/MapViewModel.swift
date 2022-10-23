//
//  MapViewModel.swift
//  KlipApp
//
//  Created by 박진섭 on 2022/10/23.
//

import MapKit

final class MapViewModel: NSObject, ObservableObject {
    @Published var currentLocation: Location?
    private let locationManager: CLLocationManager = CLLocationManager()

    override init() {
        super.init()
        setManager()
        print("init!")
    }

    deinit {
        print("deinit!")
    }

    func startUpdatingLocation() {
        checkAuthorization(self.locationManager)
    }

    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingHeading()
        self.locationManager.stopUpdatingLocation()
    }

    // 정확한 위치 사용 여부에 따른 처리 가능.
    // 정확한 위치 사용을 거부하면 == reducedAccuracy로 설정이 되어 있으면,
    // setManager함수의 accuracy setting은 무시됨.
    private func checkAccuracy() {
        switch locationManager.accuracyAuthorization {
        case .fullAccuracy:
            print("full")
        case .reducedAccuracy:
            print("reduce")
        @unknown default:
            break
        }
    }

    // Location Manager Setting
    private func setManager(_ accuracy: CLLocationAccuracy = kCLLocationAccuracyBest) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = accuracy
    }

    // 앱 권한별 상태 설정
    private func checkAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // TODO: 권한 없을시 Alert 및 설정으로 가기
            print("unAuthorized")
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        @unknown default:
            break
        }
    }

    private func convertDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd a hh시 mm분"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
    }

    // 기기의 위치권한 확인.
    private func locationServicesEnabled() async -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }

}

extension MapViewModel: CLLocationManagerDelegate {
    // 앱내 위치 권한이 바뀌었을 때
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task {
            if await locationServicesEnabled() {
                checkAuthorization(manager)
            }
        }
    }

    // 위치 정보 업데이트
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        print("Did UpDate location to \(String(describing: locations.last))")
        guard let location = locations.last else { return }
        self.currentLocation = Location(location,
                                        timeStamp: convertDate(location.timestamp))
    }

    // TODO: 위치를 가지고 오지 못할 때 에러 처리
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
    }
}

struct Location: Equatable {
    var latitude: String
    var longitude: String
    var speed: String
    var altitude: String
    var course: String
    var timeStamp: String

    func getDescription() -> String {
        return [latitude,
                longitude,
                altitude,
                speed,
                course,
                timeStamp].reduce("위치 정보") { $0 + "\n" + $1 }
    }

    init(_ location: CLLocation, timeStamp: String) {
        self.latitude = "위도: \(location.coordinate.latitude)"
        self.longitude = "경도: \(location.coordinate.longitude)"
        self.speed = "속도: \(location.speed)/ms"
        self.course = "경로: \(location.course)"
        self.altitude = "고도: \(location.altitude)"
        self.timeStamp = timeStamp
    }
}
