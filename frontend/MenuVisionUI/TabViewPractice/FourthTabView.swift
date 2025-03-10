//
//  FourthTabView.swift
//  MenuVisionUI
//
//  Created by Spencer Le on 3/9/25.
//

import SwiftUI
import AVFoundation
import Vision

struct CameraView: View {
    @StateObject private var camera = CameraManager()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var zoomFactor: CGFloat = 1.0 // Initial zoom

    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreview(session: camera.captureSession, zoomFactor: zoomFactor)
                .ignoresSafeArea()
                .gesture(
                    MagnificationGesture()
                        .onChanged { amount in
                            zoomFactor = amount
                            camera.setZoom(zoomFactor: amount)
                        }
                        .onEnded { _ in
                            // Optional: Animate back to 1.0 if you want
                        }
                )
                .onAppear {
                    print("CameraPreview appeared")
                }

            // Capture Button
            VStack {
                Spacer()
                Button(action: {
                    camera.capturePhoto()
                }) {
                    Circle()
                        .fill(.white)
                        .frame(width: 70, height: 70)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            print("CameraView appeared")
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
}

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let textRequest = VNRecognizeTextRequest()
    private var currentDevice: AVCaptureDevice? // Add device

    override init() {
        super.init()
        print("CameraManager initialized")
    }

    func checkPermissionsAndSetup(completion: @escaping (Bool, String) -> Void) {
        print("Checking camera permissions...")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera access authorized")
            DispatchQueue.global(qos: .userInitiated).async {
                self.setupCamera { success, message in
                    DispatchQueue.main.async {
                        completion(success, message)
                    }
                }
            }

        case .notDetermined:
            print("Camera access not determined, requesting...")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("Camera access granted")
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.setupCamera { success, message in
                            DispatchQueue.main.async {
                                completion(success, message)
                            }
                        }
                    }
                } else {
                    print("Camera access denied by user")
                    DispatchQueue.main.async {
                        completion(false, "Camera access denied by user")
                    }
                }
            }

        case .denied, .restricted:
            print("Camera access denied or restricted")
            DispatchQueue.main.async {
                completion(false, "Camera access denied or restricted")
            }

        @unknown default:
            print("Unknown camera authorization status")
            DispatchQueue.main.async {
                completion(false, "Unknown camera authorization status")
            }
        }
    }

    func setupCamera(completion: @escaping (Bool, String) -> Void) {
        print("Setting up camera...")

        // Make sure we're not already running
        if captureSession.isRunning {
            captureSession.stopRunning()
        }

        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()

        // Set the quality level
        if captureSession.canSetSessionPreset(.high) {
            captureSession.sessionPreset = .high
            print("Set session preset to high")
        }

        // Find available camera
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Could not find any video device")
            captureSession.commitConfiguration()
            completion(false, "Could not find any video device")
            return
        }
        
        currentDevice = videoDevice // Store the device
        print("Found video device: \(videoDevice.localizedName)")

        // Create input
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

            // Check if we can add this input
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                print("Added camera input successfully")
            } else {
                print("Could not add video device input to the session")
                captureSession.commitConfiguration()
                completion(false, "Could not add video device input to the session")
                return
            }
        } catch {
            print("Could not create video device input: \(error.localizedDescription)")
            captureSession.commitConfiguration()
            completion(false, "Could not create video device input: \(error.localizedDescription)")
            return
        }

        // Add video output
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            captureSession.addOutput(videoOutput)
            print("Added video output")

            // Set video orientation
            if let connection = videoOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                    print("Set video orientation to portrait")
                }

                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
        } else {
            print("Could not add video output")
            captureSession.commitConfiguration()
            completion(false, "Could not add video output")
            return
        }

        captureSession.commitConfiguration()
        print("Camera configuration committed")

        // Start the session on a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession.startRunning()
            let isRunning = self.captureSession.isRunning
            print("Camera session running: \(isRunning)")
            DispatchQueue.main.async {
                completion(isRunning, isRunning ? "Camera started successfully" : "Failed to start camera session")
            }
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        performOCR(on: ciImage)
    }

    func performOCR(on image: CIImage) {
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([textRequest])
            guard let observations = textRequest.results else { return }

            var detectedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                detectedText += topCandidate.string + "\n"
            }

            if !detectedText.isEmpty {
                print("OCR Result: \(detectedText)")
            }
        } catch {
            print("OCR Error: \(error)")
        }
    }

    func capturePhoto() {
        print("Photo capture requested (not implemented)")
    }

    // Zoom Function
    func setZoom(zoomFactor: CGFloat) {
        guard let device = currentDevice else { return }

        do {
            try device.lockForConfiguration()
            let clampedZoomFactor = min(max(zoomFactor, 1.0), device.activeFormat.videoMaxZoomFactor)
            device.videoZoomFactor = clampedZoomFactor
            device.unlockForConfiguration()
            print("Set zoom factor to \(clampedZoomFactor)")
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

        // Add an initializer to update the videoGravity when zoom changes
        init(session: AVCaptureSession, zoomFactor: CGFloat) {
            super.init(frame: .zero)
            videoPreviewLayer.session = session
            videoPreviewLayer.videoGravity = .resizeAspectFill // Important!
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    func makeUIView(context: Context) -> VideoPreviewView {
        print("Creating camera preview view")
        let view = VideoPreviewView(session: session, zoomFactor: zoomFactor)
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill // Set here, too!
        print("Preview layer configured")
        return view
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        print("Updating camera preview view with zoom factor \(zoomFactor)")
        uiView.videoPreviewLayer.session = session
    }
}
