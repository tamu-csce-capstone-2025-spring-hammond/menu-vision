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

    var body: some View {
        ZStack {
            if capturedImage == nil {
                // Camera View
                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        CameraPreview(
                            session: camera.captureSession,
                            zoomFactor: zoomFactor
                        )
                        .ignoresSafeArea()
                        .gesture(
                            MagnificationGesture()
                                .onChanged { amount in
                                    zoomFactor = amount
                                    camera.setZoom(zoomFactor: zoomFactor)
                                }
                        )

                        Button(action: {
                            guard !isProcessing else { return }
                            isProcessing = true
                            camera.capturePhoto { image in
                                if let image = image {
                                    capturedImage = image
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        sendImageToAPI(image: image)
                                    }
                                } else {
                                    alertMessage = "Failed to capture image"
                                    showAlert = true
                                }
                                DispatchQueue.main.async {
                                    isProcessing = false
                                }
                            }
                        }) {
                            Circle()
                                .fill(.white)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    isProcessing ?
                                        ProgressView()
                                        .progressViewStyle(
                                            CircularProgressViewStyle(tint: .blue)
                                        )
                                        .scaleEffect(1.5)
                                        : nil
                                )
                        }
                        .disabled(isProcessing)
                        .padding(.bottom, 30)
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
            } else {
                // Display Captured Image View
                VStack {
                    HStack {
                        Button(action: {
                            capturedImage = nil // Reset to camera view
                            camera.checkPermissionsAndSetup { _, _ in } // Restart Camera
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                        }
                        .padding()

                        Spacer()

                        Text("Captured Menu")
                            .font(.headline)

                        Spacer()
                    }

                    Image(uiImage: capturedImage!)
                        .resizable()
                        .scaledToFit()
                        .padding()

                    Spacer() // Push the content to the top
                }
            }
        }
    }

    func sendImageToAPI(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }

        let url = URL(string: "https://e784-165-91-13-68.ngrok-free.app/ocr/extract-menu")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"image\"; filename=\"menu.jpg\"\r\n"
                .data(using: .utf8)!
        )
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            if httpResponse.statusCode != 200 {
                print("Server error: \(httpResponse.statusCode)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString)") // Print to console
            } else {
                print("Could not parse server response")
            }
        }
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
