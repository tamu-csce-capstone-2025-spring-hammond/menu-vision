//
//  FourthTabView.swift
//  MenuVisionUI
//
//  Created by Spencer Le on 3/9/25.
//

import SwiftUI
import AVFoundation
import UIKit
import CoreLocation

struct MenuScannerView: View {
    @EnvironmentObject var restaurantData: RestaurantData
    @EnvironmentObject var dishMapping: DishMapping
    @StateObject private var camera = CameraManager()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var zoomFactor: CGFloat = 1.0
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @StateObject private var locationManager = LocationManager()
    @State private var showingLocationAlert = false
    @State private var restaurants: [Restaurant] = []
    @State private var selectedRestaurant: Restaurant?
    @State private var apiResponse: String = ""
    @State private var shouldNavigateToResult = false
    @State private var shouldNavigateToFilesListView = false
    @State private var lastSelectedRestaurantID: String?
    @State private var isAddingRestaurant = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationLink(destination: FilesListView().environmentObject(restaurantData), isActive: $shouldNavigateToFilesListView) {
                    EmptyView()
                }
                if capturedImage == nil {
                    GeometryReader { geometry in
                        ZStack(alignment: .bottom) {
                            CameraPreview(session: camera.captureSession, zoomFactor: zoomFactor)
                                .ignoresSafeArea()
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { amount in
                                            zoomFactor = amount
                                            camera.setZoom(zoomFactor: zoomFactor)
                                        }
                                )

                            VStack(spacing: 12) {
                                Group {
                                    if let displayName = selectedRestaurant?.displayName?.text {
                                        VStack(spacing: 10) {
                                            
                                            Text("\(displayName)")
                                                .font(.headline)
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .background(Color.orange300.opacity(0.6))
                                                .cornerRadius(10)
                                                
                                            
                                            /*Button("Change Restaurant") {
                                                selectedRestaurant = nil
                                            }
                                            .padding(.bottom)
                                            .foregroundColor(.red)*/
                                        }
                                    } else if !restaurants.isEmpty {
                                        VStack(spacing: 16) {
                                            Text("Select Restaurant")
                                                .font(.headline)
                                                .foregroundColor(.primary)

                                            ScrollView(showsIndicators: true) {
                                                VStack(spacing: 12) {
                                                    ForEach(restaurants, id: \.self) { restaurant in
                                                        Button(action: {
                                                            selectedRestaurant = restaurant
                                                        }) {
                                                            HStack {
                                                                Text(restaurant.displayName?.text ?? "No Name")
                                                                    .fontWeight(.medium)
                                                                    .foregroundColor(.primary)
                                                                Spacer()
                                                                if selectedRestaurant == restaurant {
                                                                    Image(systemName: "checkmark.circle.fill")
                                                                        .foregroundColor(.blue)
                                                                }
                                                            }
                                                            .padding()
                                                            .background(Color(UIColor.systemBackground))
                                                            .cornerRadius(10)
                                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal)
                                            }
                                            .scrollIndicators(.visible)
                                            .frame(maxHeight: .infinity)

                                        }
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(16)
                                        .shadow(radius: 10)
                                        .padding(.horizontal, 32)
                                    }
                                }

                                Spacer()
                                
                                HStack {
                                    
                                    if let displayName = selectedRestaurant?.displayName?.text {
                                        Button("Change Restaurant") {
                                            selectedRestaurant = nil
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                    }
                                    else{
                                        Spacer();
                                    }
                                    
                                    Spacer();
                                    
                                    Button(action: {
                                        guard !isProcessing else { return }
                                        isProcessing = true
                                        camera.capturePhoto { image in
                                            if let image = image {
                                                capturedImage = image
                                                sendImageToAPI(image: image)
                                            } else {
                                                alertMessage = "Failed to capture image"
                                                showAlert = true
                                            }
                                            DispatchQueue.main.async {
                                                isProcessing = false
                                            }
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(.white)
                                                .frame(width: 75, height: 75)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.gray.opacity(selectedRestaurant == nil ? 0.6 : 0), lineWidth: 2)
                                                )

                                            if isProcessing {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                                    .scaleEffect(1.3)
                                            } else {
                                                Image(systemName: "camera.fill")
                                                    .font(.title)
                                                    .foregroundColor(.black.opacity(selectedRestaurant == nil ? 0.3 : 1))
                                            }
                                        }
                                    }
                                    .disabled(selectedRestaurant == nil || isProcessing)
                                    .opacity(selectedRestaurant == nil ? 0.4 : 1)
                                    .padding(.bottom, 30)
                                    
                                    Spacer();
                                    
                                    if let displayName = selectedRestaurant?.displayName?.text {
                                        
                                            NavigationLink(destination: FirstTabView().environmentObject(dishMapping)){
                                                Text("View AR Collection")
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 10)
                                                    .background(Color.blue)
                                                    .foregroundColor(.white)
                                                    .clipShape(Capsule())
                                            }                                        
                                        
                                    }
                                    else{
                                        Spacer();
                                    }
                                    
                                }

                                
                            }
                            .padding(.horizontal)
                        }
                    }
                    .onAppear {
                        camera.checkPermissionsAndSetup { success, message in
                            if !success {
                                alertMessage = message
                                showAlert = true
                            }
                        }
                        locationManager.getLocationOnce { location in
                            if let location = location {
                                fetchNearbyRestaurants(
                                    longitude: location.coordinate.longitude,
                                    latitude: location.coordinate.latitude
                                )
                            } else {
                                alertMessage = "Could not retrieve location. Please ensure location services are enabled."
                                showAlert = true
                            }
                        }
                        
                        dishMapping.setStartedLoading();
                        
                        if (selectedRestaurant == nil){
                            dishMapping.setStartedDownloading();
                        }
                    }
                    .onDisappear {
                        camera.stopCameraSafely()
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Camera Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    .alert(isPresented: $showingLocationAlert) {
                        Alert(
                            title: Text("Location Access Denied"),
                            message: Text("Please enable location services in Settings for this app to function correctly."),
                            primaryButton: .default(Text("Settings"), action: {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }),
                            secondaryButton: .cancel()
                        )
                    }
                    .onChange(of: locationManager.authorizationStatus) { newStatus in
                        showingLocationAlert = (newStatus == .denied || newStatus == .restricted)
                    }
                    .task(id: selectedRestaurant?.id) {
                        if let id = selectedRestaurant?.id,
                           id != lastSelectedRestaurantID {
                            
                            lastSelectedRestaurantID = id
                            restaurantData.restaurant_id = id
                            
                            // Add restaurant to database if needed
                            if let restaurant = selectedRestaurant {
                                await addRestaurantToDatabase(restaurant: restaurant)
                            }
                            
                            print("\nAttempting download for restaurant: \(id)")
                            
                            
                            Task{
                                dishMapping.setStartedDownloading();
                                dishMapping.setStartedLoading();
                                
                                dishMapping.modelsByDishName.removeAll();
                                
                                var retryCount = 0
                                let maxRetries = 3 // Define the number of retry attempts
                                let delayInSeconds = 2 // Define the delay between retries

                                while retryCount < maxRetries {
                                    
                                    if (id != selectedRestaurant?.id){
                                        break;
                                    }
                                    
                                    let models = await ModelFileManager.shared.clearAndDownloadFiles(for: id, dishMapping: dishMapping)

                                    if !models.isEmpty {
                                        if (id == selectedRestaurant?.id){
                                            dishMapping.setModels(models);
                                        }
                                        break // Exit the loop if download is successful
                                    } else {
                                        print("Model list is empty. Retrying in \(delayInSeconds) seconds... (Attempt \(retryCount + 1) of \(maxRetries))")
                                        retryCount += 1
                                        try? await Task.sleep(nanoseconds: UInt64(delayInSeconds) * 1_000_000_000) // Introduce a delay
                                    }
                                }

                                if retryCount == maxRetries && dishMapping.modelsByDishName.isEmpty {
                                    print("Failed to download models after \(maxRetries) retries.")
                                    DispatchQueue.main.async {
                                        alertMessage = "Failed to download AR models for this restaurant. Either no models have been uploaded yet or the internet connection is weak."
                                        showAlert = true
                                    }
                                }
                                
                                if (id == selectedRestaurant?.id){
                                    dishMapping.setFinishedDownloading();
                                }
                                
                            
                            }
                            
                            //sort dishMapping based on rating
                            
                            
                            
                            //set finished loading is called in the arview container
                            
                        }

                    }
                } else {
                    // Add potential Loading bar here ---
                    VStack {
                        HStack {
                            Button(action: {
                                capturedImage = nil
                                apiResponse = ""
                                camera.checkPermissionsAndSetup { _, _ in }
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                            }
                            .padding()
                            Spacer()
                        }
                        Image(uiImage: capturedImage!)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .padding()

                        Spacer()
                    }
                                        
                }
            }
            .navigationDestination(isPresented: $shouldNavigateToResult) {
                MenuListView(response: apiResponse)
            }
        }
    }

    func fetchNearbyRestaurants(longitude: Double, latitude: Double) {
        let urlString = "https://menu-vision-b202af7ea787.herokuapp.com/general/nearby-restaurants/\(longitude)/\(latitude)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else { return }

            do {
                let decodedResponse = try JSONDecoder().decode(RestaurantResponse.self, from: data)
                
                let capstoneCafe = Restaurant(
                    id: "ChIJ92rcyJWDRoYRotK6QCjsFf8",
                    placeId: "ChIJ92rcyJWDRoYRotK6QCjsFf8",
                    displayName: DisplayName(text: "Capstone Cafe", languageCode: "en")
                )
                
                let reveilleCafe = Restaurant(
                    id: "dknsdknslnslsnlsnls",
                    placeId: "slnlsnlsnslnsls",
                    displayName: DisplayName(text: "Reveille Cafe", languageCode: "en")
                )

                
                DispatchQueue.main.async {
                    self.restaurants = [capstoneCafe, reveilleCafe] + (decodedResponse.places ?? [])
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }

    func sendImageToAPI(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let userId = UserDefaults.standard.integer(forKey: "user_id");

        let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ocr/extract-menu/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"menu.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            if let jsonString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.apiResponse = jsonString
                    self.shouldNavigateToResult = true
//                    print("shouldNavigateToResult", self.shouldNavigateToResult)

                }
            }
        }.resume()
    }

    private func addRestaurantToDatabase(restaurant: Restaurant) async {
        guard let id = restaurant.id, let name = restaurant.displayName?.text else { return }
        
        let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/restaurant")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "restaurant_id": id,
            "name": name
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    print("Restaurant added successfully")
                } else if httpResponse.statusCode == 409 {
                    print("Restaurant already exists")
                } else {
                    print("Error adding restaurant: \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("Error adding restaurant: \(error)")
        }
    }
}

extension CameraManager {
    func stopCameraSafely() {
        DispatchQueue.global(qos: .background).async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                // Release inputs and outputs
                for input in self.captureSession.inputs {
                    self.captureSession.removeInput(input)
                }
                for output in self.captureSession.outputs {
                    self.captureSession.removeOutput(output)
                }

            }
        }
    }
}


// Response struct to handle "places" key
struct RestaurantResponse: Codable {
    let places: [Restaurant]?
}

// Define Restaurant struct - adjust properties to match your API response
struct Restaurant: Codable, Hashable {
    let id: String?
    let placeId: String?
    let displayName: DisplayName?
    // Add other properties from your Restaurant JSON here

    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Ensure unique hash based on the restaurant's ID
    }

    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.id == rhs.id
    }
}

struct DisplayName: Codable {
    let text: String?
    let languageCode: String?
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined // Initialize

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func getLocationOnce(completion: @escaping (CLLocation?) -> Void) {
        locationManager.requestWhenInUseAuthorization() // Request authorization
        locationManager.delegate = self // Ensure delegate is set

        // Check authorization status
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Location access granted, start one-time location update
            locationManager.startUpdatingLocation()
            oneTimeLocationCompletion = completion // Store completion handler
        case .denied, .restricted:
            // Location access denied or restricted
            print("Location access denied or restricted")
            completion(nil) // Call completion handler with nil
        case .notDetermined:
            // Location access not determined, wait for didChangeAuthorization
            print("Location access not determined.")
            locationManager.startUpdatingLocation()
            oneTimeLocationCompletion = completion
        default:
            print("Unhandled location authorization status")
            completion(nil)
        }
    }

    private var oneTimeLocationCompletion: ((CLLocation?) -> Void)?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        print("One-time location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        locationManager.stopUpdatingLocation() // Stop after getting the first location
        oneTimeLocationCompletion?(location) // Call completion handler
        oneTimeLocationCompletion = nil // Clear completion handler
        locationManager.delegate = nil
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
        switch status {
        case .denied, .restricted:
            print("Location access denied or restricted")
            oneTimeLocationCompletion?(nil) // Notify about the denial
            oneTimeLocationCompletion = nil
            locationManager.delegate = nil // remove delegate
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location access authorized")
        case .notDetermined:
            print("Location access not determined.")
        default:
            print("Unhandled location authorization status")
            oneTimeLocationCompletion?(nil) // Notify about the denial
            oneTimeLocationCompletion = nil
            locationManager.delegate = nil // remove delegate
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
        locationManager.stopUpdatingLocation()
        oneTimeLocationCompletion?(nil) // Notify about the error
        oneTimeLocationCompletion = nil
        locationManager.delegate = nil // remove delegate
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("User has denied location access.")
                // Handle denial (e.g., show an alert)
            case .locationUnknown:
                print("Location is currently unknown.")
                // Handle the unknown location (perhaps a retry mechanism)
            default:
                print("Other CoreLocation error: \(clError.localizedDescription)")
            }
        }
    }
}

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var currentDevice: AVCaptureDevice?
    private var photoCaptureCompletion: ((UIImage?) -> Void)?

    func checkPermissionsAndSetup(completion: @escaping (Bool, String) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera(completion: completion)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCamera(completion: completion)
                } else {
                    completion(false, "Camera access denied")
                }
            }
        case .denied, .restricted:
            completion(false, "Camera access denied")
        @unknown default:
            completion(false, "Unknown camera authorization status")
        }
    }

    func setupCamera(completion: @escaping (Bool, String) -> Void) {
        captureSession.beginConfiguration()

        var videoDevice: AVCaptureDevice?

        // Try to get ultra-wide camera first if available
        if #available(iOS 13.0, *) {
            videoDevice = AVCaptureDevice.default(
                .builtInUltraWideCamera,
                for: .video,
                position: .back
            )
        }

        // Fall back to wide angle if ultra-wide is not available
        if videoDevice == nil {
            videoDevice = AVCaptureDevice.default(for: .video)
        }

        guard let device = videoDevice,
              let videoDeviceInput = try? AVCaptureDeviceInput(device: device)
        else {
            completion(false, "Failed to access camera")
            return
        }

        currentDevice = device

        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
        }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        // Force portrait orientation
        if let connection = photoOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }

        captureSession.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                completion(true, "Camera setup complete")
            }
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard captureSession.isRunning else {
            completion(nil)
            return
        }

        self.photoCaptureCompletion = completion

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            print("Error capturing photo: \(error)")
            photoCaptureCompletion?(nil)
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData)
        else {
            print("Could not create image from photo data")
            photoCaptureCompletion?(nil)
            return
        }

        photoCaptureCompletion?(image)

        // Stop the capture session after taking the photo
        DispatchQueue.global(qos: .userInitiated).async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }

    func setZoom(zoomFactor: CGFloat) {
        guard let device = currentDevice else { return }

        do {
            try device.lockForConfiguration()
            let clampedZoomFactor = min(
                max(zoomFactor, 1.0),
                device.activeFormat.videoMaxZoomFactor
            )
            device.videoZoomFactor = clampedZoomFactor
            device.unlockForConfiguration()
        } catch {
            print("Error setting zoom: \(error)")
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    let zoomFactor: CGFloat

    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }

    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }
}
