//
//  ScanView.swift
//  MenuVision
//
//  Created by Kim Chen on 3/2/25.
//


import SwiftUI
import RealityKit

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

extension ScanView {

    // creates directory to hold scans (available only in app's sandboxed documents directory)
    func createNewScanDirectory() -> URL? {
        guard let capturesFolder = getRootScansFolder() else { return nil }

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
        guard exists, isDirectory.boolValue else { return nil }
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

    var body: some View {
        ZStack(alignment: .bottom) {
            if let session {
                ObjectCaptureView(session: session)
                
                VStack(spacing: 16) {
                  
                    if session.state == .ready || session.state == .detecting {
                        CreateButton(session: session)
                    }
                    
                    Text(session.state.label)
                        .bold()
                        .foregroundStyle(.yellow)
                        .padding(.bottom)
                }
            }
        }
        // this allows the directory and session to be created/started in the background
        .task {
            guard let directory = createNewScanDirectory() else { return }
            session = ObjectCaptureSession()
            imageFolderPath = directory.appending(path: "Images/")
            guard let imageFolderPath else { return }
            session?.start(imagesDirectory: imageFolderPath)
        }
        // upon finishing the scan, we will change our session state to 'finished'
        .onChange(of: session?.userCompletedScanPass) { _, newValue in
            if let newValue,
               newValue {
                session?.finish()
            }
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


