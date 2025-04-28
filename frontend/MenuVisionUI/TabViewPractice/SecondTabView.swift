//
//  ScanView.swift
//  MenuVision
//
//  Created by Kim Chen on 3/2/25.
//


import SwiftUI
import RealityKit

import QuickLookThumbnailing

/// Extension to add a human-readable label for each ObjectCaptureSession state.
extension ObjectCaptureSession.CaptureState {

    var label: String {
        switch self {
        case .initializing:
//            "initializing"
            ""
        case .ready:
//            "ready"
            ""
        case .detecting:
//            "detecting"
            ""
        case .capturing:
//            "capturing"
            ""
        case .finishing:
//            "finishing"
            ""
        case .completed:
//            "completed"
            ""
        case .failed(let error):
            "failed: \(String(describing: error))"
        @unknown default:
            fatalError("unknown default: \(self)")
        }
    }
}

/// A button that handles both detection and capturing depending on the session state.
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

/// A view that previews a scanned object with options to accept, retake, or assign the model.
struct ScanPreviewView: View {
    let thumbnail: UIImage
    let onAccept: () -> Void
    let onRetake: () -> Void
    let onAssignModel: () async -> Void

    var body: some View {
        VStack(spacing: 20) {
            
            Spacer(minLength: 60)
            
            Text("Click to Preview")
                .font(.title2)
                .bold()
        Button(action: onAccept) {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .cornerRadius(12)
                .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
            
            Spacer().frame(height: 20)
            
            VStack(spacing: 20) {
                Button("Retake", action: onRetake)
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 251 / 255, green: 188 / 255, blue: 149 / 255))
                    .frame(width: 200, height: 44)
                    .background(Color(red: 251 / 255, green: 188 / 255, blue: 149 / 255))
                    .cornerRadius(12)
                
                Button("Accept") {
                    Task {
                        await onAssignModel()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 248 / 255, green: 141 / 255, blue: 75 / 255))
                .frame(width: 200, height: 44)
                .background(Color(red: 248 / 255, green: 141 / 255, blue: 75 / 255))
                .cornerRadius(12)
            }



            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(
            gradient: Gradient(colors: [/*Color(red: 218/255, green: 226/255, blue: 248/255)*/Color(red: 250 / 255, green: 172 / 255, blue: 124 / 255), Color.white]),
            startPoint: .top,
            endPoint: .bottom
        ))
        
    }
}


/// A view that manages the 3D scanning, processing, and model preview workflow.
struct ScanView: View {
    
    @State private var session: ObjectCaptureSession?
    @State private var imageFolderPath: URL?
    @State private var photogrammetrySession: PhotogrammetrySession?
    @State private var modelFolderPath: URL?
    @State private var isProgressing = false
    @State private var quickLookIsPresented = false
    
    @State private var scanPassCount = 0
    let requiredScanPasses = 2
    @State private var showScanPassPrompt = false
    
    @State private var showScanPreviewPage = false
    @State private var thumbnailImage: UIImage?
    @State private var thumbnailURL: URL?
    
    @State private var showModelAssignmentView = false
    @State private var uploadedModelId: String = ""
    @State private var uuid: String = ""
    
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
            if let newValue, newValue {
                scanPassCount += 1
                print("Completed scan pass \(scanPassCount)")
                
                // Only prompt after the first scan pass
                if scanPassCount == 1 {
                    showScanPassPrompt = true
                } else {
                    session?.finish()
                }
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
        .sheet(isPresented: $showScanPreviewPage) {
            if let thumbnailImage, let modelPath {

                ScanPreviewView(
                    thumbnail: thumbnailImage,
                    onAccept: {
                        showScanPreviewPage = false
                        quickLookIsPresented = true
                    },
                    onRetake: {
                        showScanPreviewPage = false
                        scanPassCount = 0
                        Task {
                            guard let directory = createNewScanDirectory() else { return }
                            modelFolderPath = directory.appending(path: "Models/")
                            imageFolderPath = directory.appending(path: "Images/")
                            session = ObjectCaptureSession()
                            session?.start(imagesDirectory: imageFolderPath!)
                        }
                    },
                    onAssignModel: {
                        showScanPreviewPage = false
                        showModelAssignmentView = true
                        // only once the model is accepted do we want to save to s3 buckets
                        let filesListView = FilesListView()
//                        uuid = UUID().uuidString
                        await filesListView.s3testing(modelPath: modelPath, identificationNumber: uuid)
                        if let url = thumbnailURL {
                            await filesListView.s3testing(modelPath: url, identificationNumber: uuid)
                        } else {
                            print("Error: thumbnailURL is nil")
                            // Handle the error or show a UI alert
                        }

                        
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showModelAssignmentView) {
            ModelAssignmentView(
                restaurantId: "ChIJ92rcyJWDRoYRotK6QCjsFf8",
                modelId: uploadedModelId,
                uploadedBy: "1"  // Replace with actual user ID if needed
            )
        }

        .sheet(isPresented: $quickLookIsPresented) {
            if let modelPath {
                ARQuickLookView(modelFile: modelPath) {
                    quickLookIsPresented = false
                    showScanPreviewPage = true
                }
            }
        }
        .alert("Scan more angles?", isPresented: $showScanPassPrompt) {
            Button("Yes, continue scan") {
                try? session?.beginNewScanPass()
            }
            Button("No, finish") {
                session?.finish()
                
            }
        } message: {
            Text("Would you like to add another scan pass for better 3D quality?")
        }
    }
}

/// Extension for ScanView to manage file system and reconstruction tasks.
extension ScanView {
    /// Creates a new scan directory under the app's document folder.
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
    
    /// Returns the root folder where scans are stored.
    private func getRootScansFolder() -> URL? {
        guard let documentFolder = try? FileManager.default.url(for: .documentDirectory,
                                                                in: .userDomainMask,
                                                                appropriateFor: nil,
                                                                create: false)
        else { return nil }
        return documentFolder.appendingPathComponent("Scans/", isDirectory: true)
    }
    
    /// Starts photogrammetry reconstruction of captured images into a 3D model.
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
//                    quickLookIsPresented = true
                    // uploading usdz file to s3 bucket
//                    let filesListView = FilesListView()
                    uuid = UUID().uuidString
                    generateThumbnailRepresentations(modelURL: modelPath, identificationNumber: uuid)
                default:
                    break
                }
            }
            
        } catch {
            print("error", error)
        }
    }
    
    /// Generates a thumbnail image from a USDZ model file.
    func generateThumbnailRepresentations(modelURL: URL, identificationNumber: String) {
        
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
                    
                    self.thumbnailImage = thumbnail.uiImage
//                    self.thumbnailURL = thumbnailURL
                    self.showScanPreviewPage = true
                    
                    self.uploadedModelId = identificationNumber
                    
                    print("Thumbnail generated successfully!")

                    // save thumbnail in app's document directory (sandbox)
                    if let imageData = thumbnail.uiImage.pngData() {
                        do {
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let thumbnailURL = documentsDirectory.appendingPathComponent("thumbnail.png")
                            
                            try imageData.write(to: thumbnailURL)
                            print("Thumbnail saved at \(thumbnailURL)")
                            
                            self.thumbnailURL = thumbnailURL
                            
//                            }
                        } catch {
                            print("Failed to save thumbnail: \(error)")
                        }
                    }
                }
            }
        }
    }

    
}

struct ScanPreviewViewProvider: PreviewProvider {
    static var previews: some View {
        let thumbnailImage: UIImage = {
            if let url = Bundle.main.url(forResource: "1C3AB288-5AB9-4110-9C88-3ADDA8B9A032", withExtension: "png"),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                return image
            } else {
                return UIImage()
            }
        }()
        
        return ScanPreviewView(
            thumbnail: thumbnailImage,
            onAccept: {},
            onRetake: {},
            onAssignModel: {}
        )
    }
}
