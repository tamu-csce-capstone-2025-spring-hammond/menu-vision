//
//  FourthTabView.swift
//  MenuVisionUI
//
//  Created by Spencer Le on 3/9/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct MenuScannerView: View {
    @StateObject private var camera = CameraManager()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var zoomFactor: CGFloat = 1.0
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @State private var apiResponse: String = ""
    @State private var showResults = false

    var body: some View {
        ZStack {
            if !showResults {
                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        // Camera Preview
                        CameraPreview(session: camera.captureSession, zoomFactor: zoomFactor)
                            .ignoresSafeArea()
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { amount in
                                        zoomFactor = amount
                                        camera.setZoom(zoomFactor: zoomFactor)
                                    }
                            )

                        // Capture Button
                        Button(action: {
                            isProcessing = true
                            camera.capturePhoto { image in
                                if let image = image {
                                    self.capturedImage = image
                                    sendImageToAPI(image: image)
                                } else {
                                    self.isProcessing = false
                                    self.alertMessage = "Failed to capture image"
                                    self.showAlert = true
                                }
                            }
                        }) {
                            Circle()
                                .fill(.white)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    isProcessing ?
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                            .scaleEffect(1.5)
                                        : nil
                                )
                        }
                        .disabled(isProcessing)
                        .padding(.bottom, 30)
                    }
                }
            } else {
                // Results view
                VStack {
                    HStack {
                        Button(action: {
                            showResults = false
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                        }
                        .padding()
                        
                        Spacer()
                        
                        Text("Menu Analysis Results")
                            .font(.headline)
                        
                        Spacer()
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            if let image = capturedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            }
                            
                            Text("API Response:")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text(apiResponse)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .onAppear {
            camera.checkPermissionsAndSetup { success, message in
                if !success {
                    alertMessage = message
                    showAlert = true
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Camera Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func sendImageToAPI(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            self.isProcessing = false
            self.alertMessage = "Failed to convert image to data"
            self.showAlert = true
            return
        }
        
        // Create URL request
        let url = URL(string: "https://8883-198-217-29-131.ngrok-free.app/ocr/extract-menu")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Generate boundary string
        let boundary = UUID().uuidString
        
        // Set content type
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create body
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"menu.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End of form
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Set body
        request.httpBody = body
        
        // Create task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isProcessing = false
                
                if let error = error {
                    self.alertMessage = "Network error: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.alertMessage = "Invalid response"
                    self.showAlert = true
                    return
                }
                
                if httpResponse.statusCode != 200 {
                    self.alertMessage = "Server error: \(httpResponse.statusCode)"
                    self.showAlert = true
                    return
                }
                
                guard let data = data else {
                    self.alertMessage = "No data received"
                    self.showAlert = true
                    return
                }
                
                // Try to parse the response as JSON
                if let jsonString = String(data: data, encoding: .utf8) {
                    self.apiResponse = jsonString
                    self.showResults = true
                } else {
                    self.alertMessage = "Could not parse server response"
                    self.showAlert = true
                }
            }
        }
        
        // Start task
        task.resume()
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
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            completion(false, "Failed to access camera")
            return
        }
        
        currentDevice = videoDevice

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

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            photoCaptureCompletion?(nil)
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Could not create image from photo data")
            photoCaptureCompletion?(nil)
            return
        }

        photoCaptureCompletion?(image)
    }

    func setZoom(zoomFactor: CGFloat) {
        guard let device = currentDevice else { return }

        do {
            try device.lockForConfiguration()
            let clampedZoomFactor = min(max(zoomFactor, 1.0), device.activeFormat.videoMaxZoomFactor)
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
