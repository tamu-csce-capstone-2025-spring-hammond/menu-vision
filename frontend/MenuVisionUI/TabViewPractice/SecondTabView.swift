//
//  ScanView.swift
//  MenuVision
//
//  Created by Kim Chen on 3/2/25.
//


import SwiftUI
import RealityKit

import QuickLookThumbnailing

extension ObjectCaptureSession.CaptureState {

    var label: String {
        switch self {
        case .initializing:
            "initializing"
        case .ready:
            "ready"
        case .detecting:
            "detecting"
        case .capturing:
            "capturing"
        case .finishing:
            "finishing"
        case .completed:
            "completed"
        case .failed(let error):
            "failed: \(String(describing: error))"
        @unknown default:
            fatalError("unknown default: \(self)")
        }
    }
}

// this button handles both detection and capturing, depending on the session's current state
@MainActor
struct CreateButton: View {
    let session: ObjectCaptureSession

    var body: some View {
        Button(action: {
            performAction()
        }, label: {
            Text(label)
            .foregroundStyle(.white)
            .padding()
            .background(.tint)
            .clipShape(Capsule())
        })
    }

    private var label: LocalizedStringKey {
        if session.state == .ready {
            return "Start detecting"
        } else if session.state == .detecting {
            return "Start capturing"
        } else {
            return "Undefined"
        }
    }

    private func performAction() {
        if session.state == .ready {
            let isDetecting = session.startDetecting()
            print(isDetecting ? "Start detecting" : "Not detecting")
        } else if session.state == .detecting {
            session.startCapturing()
        } else {
            print("Undefined")
        }
    }
}

struct ScanView: View {
    
    @State private var session: ObjectCaptureSession?
    @State private var imageFolderPath: URL?
    @State private var photogrammetrySession: PhotogrammetrySession?
    @State private var modelFolderPath: URL?
    @State private var isProgressing = false
    @State private var quickLookIsPresented = false
    
    var modelPath: URL? {
        return modelFolderPath?.appending(path: "model.usdz")
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            if (!ObjectCaptureSession.isSupported){
                Text("Your device does not support AR scanning");
            }
            
            if let session {
                ObjectCaptureView(session: session)
                
                VStack(spacing: 16) {
                    
                    if session.state == .ready || session.state == .detecting {
                        // Detect and Capture
                        CreateButton(session: session)
                    }
                    
                    HStack {
                        Text(session.state.label)
                            .bold()
                            .foregroundStyle(.yellow)
                            .padding(.bottom)
                    }

                    
                }
            }
            
            if isProgressing {
                Color.black.opacity(0.4)
                    .overlay {
                        VStack {
                            ProgressView()
                        }
                    }
            }
            
        }
        .task {
            guard let directory = createNewScanDirectory()
            else { return }
            
            if (!ObjectCaptureSession.isSupported){
                print("Not supported");
                return;
            }
            
            session = ObjectCaptureSession()
            
            modelFolderPath = directory.appending(path: "Models/")
            imageFolderPath = directory.appending(path: "Images/")
            guard let imageFolderPath else { return }
            session?.start(imagesDirectory: imageFolderPath)
            
//            generateThumbnailRepresentations()
            
        }
        .onChange(of: session?.userCompletedScanPass) { _, newValue in
            if let newValue,
               newValue {
                // This time, I've completed one scan pass.
                // However, Apple recommends that the scan pass should be done three times.
                session?.finish()
            }
        }
        .onChange(of: session?.state) { _, newValue in
            if newValue == .completed {
                session = nil
                
                Task {
                    await startReconstruction()
                }
            }
        }
        .sheet(isPresented: $quickLookIsPresented) {
            
            if let modelPath {
                ARQuickLookView(modelFile: modelPath) {
                    guard let directory = createNewScanDirectory()
                    else { return }
                    quickLookIsPresented = false
                    // TODO: Restart ObjectCapture
                }
            }
        }
    }
}

extension ScanView {
    
    func createNewScanDirectory() -> URL? {
        guard let capturesFolder = getRootScansFolder()
        else { return nil }
        
        let formatter = ISO8601DateFormatter()
        let timestamp = formatter.string(from: Date())
        let newCaptureDirectory = capturesFolder.appendingPathComponent(timestamp,
                                                                        isDirectory: true)
        print("Start creating capture path: \(newCaptureDirectory)")
        let capturePath = newCaptureDirectory.path
        do {
            try FileManager.default.createDirectory(atPath: capturePath,
                                                    withIntermediateDirectories: true)
        } catch {
            print("Failed to create capture path: \(capturePath) with error: \(String(describing: error))")
        }
        
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: capturePath,
                                                    isDirectory: &isDirectory)
        guard exists, isDirectory.boolValue
        else { return nil }
        print("New capture path was created")
        return newCaptureDirectory
    }
    
    private func getRootScansFolder() -> URL? {
        guard let documentFolder = try? FileManager.default.url(for: .documentDirectory,
                                                                in: .userDomainMask,
                                                                appropriateFor: nil,
                                                                create: false)
        else { return nil }
        return documentFolder.appendingPathComponent("Scans/", isDirectory: true)
    }
    
    private func startReconstruction() async {
        guard let imageFolderPath,
              let modelPath else { return }
        isProgressing = true
        do {
            photogrammetrySession = try PhotogrammetrySession(input: imageFolderPath)
            guard let photogrammetrySession else { return }
            try photogrammetrySession.process(requests: [.modelFile(url: modelPath)])
            for try await output in photogrammetrySession.outputs {
                switch output {
                case .requestError, .processingCancelled:
                    isProgressing = false
                    self.photogrammetrySession = nil
                    // TODO: Restart ObjectCapture
                case .processingComplete:
                    isProgressing = false
                    self.photogrammetrySession = nil
                    quickLookIsPresented = true
                    // uploading usdz file to s3 bucket
                    let filesListView = FilesListView()
                    let uuid = UUID().uuidString
                    await filesListView.s3testing(modelPath: modelPath, identificationNumber: uuid)
                    
                    generateThumbnailRepresentations(modelURL: modelPath, identificationNumber: uuid)
                default:
                    break
                }
            }
            
        } catch {
            print("error", error)
        }
    }
    
    // generate thumbnail
    func generateThumbnailRepresentations(modelURL: URL, identificationNumber: String) {
//        guard let modelURL = Bundle.main.url(forResource: "onion_1", withExtension: "usdz") else {
//            print("Model file not found in bundle")
//            return
//        }
        
        let size = CGSize(width: 100, height: 100)
        let scale = UIScreen.main.scale
        
        let request = QLThumbnailGenerator.Request(fileAt: modelURL,
                                                   size: size,
                                                   scale: scale,
                                                   representationTypes: .all)

        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error generating thumbnail: \(error.localizedDescription)")
                } else if let thumbnail = thumbnail {
                    print("Thumbnail generated successfully!")

                    // save thumbnail in app's document directory (sandbox)
                    if let imageData = thumbnail.uiImage.pngData() {
                        do {
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let thumbnailURL = documentsDirectory.appendingPathComponent("thumbnail.png")
                            
                            try imageData.write(to: thumbnailURL)
                            print("Thumbnail saved at \(thumbnailURL)")
                            
                            // upload to s3 (maybe fix code not to instantiate FilesListView twice)
                            let filesListView = FilesListView()
                            Task {
                                await filesListView.s3testing(modelPath: thumbnailURL, identificationNumber: identificationNumber)
                            }
                        } catch {
                            print("Failed to save thumbnail: \(error)")
                        }
                    }
                }
            }
        }
    }

    
}
