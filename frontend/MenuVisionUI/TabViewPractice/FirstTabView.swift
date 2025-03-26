//
//  ScanView.swift
//  MenuVision
//
//  Created by Kim Chen on 3/2/25.
//


import SwiftUI
import RealityKit

//import S3Components.FilesListView

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

//extension ScanView {
//
//    // creates directory to hold scans (available only in app's sandboxed documents directory)
//    func createNewScanDirectory() -> URL? {
//        guard let capturesFolder = getRootScansFolder() else { return nil }
//
//        let formatter = ISO8601DateFormatter()
//        let timestamp = formatter.string(from: Date())
//        let newCaptureDirectory = capturesFolder.appendingPathComponent(timestamp,
//                                                                        isDirectory: true)
//        print("Start creating capture path: \(newCaptureDirectory)")
//        let capturePath = newCaptureDirectory.path
//        do {
//            try FileManager.default.createDirectory(atPath: capturePath,
//                                                    withIntermediateDirectories: true)
//        } catch {
//            print("Failed to create capture path: \(capturePath) with error: \(String(describing: error))")
//        }
//
//        var isDirectory: ObjCBool = false
//        let exists = FileManager.default.fileExists(atPath: capturePath,
//                                                    isDirectory: &isDirectory)
//        guard exists, isDirectory.boolValue else { return nil }
//        print("New capture path was created")
//        return newCaptureDirectory
//    }
//
//    private func getRootScansFolder() -> URL? {
//        guard let documentFolder = try? FileManager.default.url(for: .documentDirectory,
//                                                                in: .userDomainMask,
//                                                                appropriateFor: nil,
//                                                                create: false)
//        else { return nil }
//        return documentFolder.appendingPathComponent("Scans/", isDirectory: true)
//    }
//
//    private func startReconstruction() async {
////        print("At Reconstruction")
//        guard let imageFolderPath,
//              let modelPath else { return }
//        isProgressing = true
//        print("At Reconstruction and \(isProgressing)")
//        do {
//            photogrammetrySession = try PhotogrammetrySession(input: imageFolderPath)
//            guard let photogrammetrySession else { return }
//            try photogrammetrySession.process(requests: [.modelFile(url: modelPath)])
//            for try await output in photogrammetrySession.outputs {
//                switch output {
//                case .requestError, .processingCancelled:
//                    isProgressing = false
//                    self.photogrammetrySession = nil
//                    // TODO: Restart ObjectCapture
//                case .processingComplete:
//                    isProgressing = false
//                    self.photogrammetrySession = nil
//                    print("Done! \(modelPath)")
//                    quickLookIsPresented = true
//                default:
//                    break
//                }
//            }
//
//        } catch {
//            print("error", error)
//        }
//    }
//}

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

//struct ScanView: View {
//    @State private var session: ObjectCaptureSession?
//    @State private var imageFolderPath: URL?
//    @State private var photogrammetrySession: PhotogrammetrySession?
//    @State private var modelFolderPath: URL?
//    @State private var isProgressing = false
//
//    @State private var quickLookIsPresented = false
//
//    var modelPath: URL? {
//        return modelFolderPath?.appending(path: "model.usdz")
//    }
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            if let session {
//                ObjectCaptureView(session: session)
//
//                VStack(spacing: 16) {
//
//                    if session.state == .ready || session.state == .detecting {
//                        CreateButton(session: session)
//                    }
//
//                    Text(session.state.label)
//                        .bold()
//                        .foregroundStyle(.yellow)
//                        .padding(.bottom)
//                }
//            }
//            if isProgressing {
//                Color.black.opacity(0.4)
//                .overlay {
//                    VStack {
//                        ProgressView()
//                    }
//                }
//            }
//        }
//        // this allows the directory and session to be created/started in the background
//        .task {
//            guard let directory = createNewScanDirectory() else { return }
//            if (ObjectCaptureSession.isSupported == true){
//                session = ObjectCaptureSession()
//                modelFolderPath = directory.appending(path: "Models/")
//                imageFolderPath = directory.appending(path: "Images/")
//                guard let imageFolderPath else { return }
//                session?.start(imagesDirectory: imageFolderPath)
//            }
//        }
//        // upon finishing the scan, we will change our session state to 'finished'
//        .onChange(of: session?.userCompletedScanPass) { _, newValue in
//            if let newValue,
//               newValue {
//                session?.finish()
//            }
//        }
//        .onChange(of: session?.state) { _, newValue in
//            if newValue == .completed {
//                session = nil
//
//                Task {
//                    print("Starting Reconstruction")
//                    await startReconstruction()
//                }
//            }
//        }
//        .sheet(isPresented: $quickLookIsPresented) {
//
//            if let modelPath {
//                ARQuickLookView(modelFile: modelPath) {
//                    guard let directory = createNewScanDirectory()
//                    else { return }
//                    quickLookIsPresented = false
//                    // TODO: Restart ObjectCapture
//                }
//            }
//        }
//    }
//}

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
            session = ObjectCaptureSession()
            
            modelFolderPath = directory.appending(path: "Models/")
            imageFolderPath = directory.appending(path: "Images/")
            guard let imageFolderPath else { return }
            session?.start(imagesDirectory: imageFolderPath)
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
                    let filesListView = FilesListView()
                    await filesListView.s3testing(modelPath: modelPath)
                default:
                    break
                }
            }
            
        } catch {
            print("error", error)
        }
    }
    
    
    
}








































////
////  FirstTabView.swift
////  MenuVisionUI
////
////  Created by Sam Zhou on 3/1/25.
////
//import SwiftUI
//
//
//struct FirstTabView: View {
//    var body: some View {
//        VStack {
//            Text("Home Screen")
//                .font(.largeTitle)
//                .padding()
//            Image(systemName: "house.fill")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 100, height: 100)
//        }
//    }
//}



