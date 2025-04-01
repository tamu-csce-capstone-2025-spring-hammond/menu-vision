//
//  FilesListView.swift
//  Swift_s3_practicing
//
//  Created by Sam Zhou on 3/23/25.
//

import SwiftUI
import Foundation
@preconcurrency import AWSS3
import AWSClientRuntime
import ClientRuntime
import AWSSDKIdentity

struct FilesListView: View {
    @State private var fileNames: [String] = []
    @EnvironmentObject var restaurantData: RestaurantData
    @State private var hasFetchedModels = false
    
    var body: some View {
        NavigationView {
            VStack {
                List(fileNames, id: \.self) { fileName in
                    Text(fileName)
                }
                .refreshable {
                    await loadFiles()
                }
                Button("Download Files") {
                    Task {
                        let keys = await fetchModelKeysFromAPI()
                        await asyncDownload(keys: keys)
//                        await downloadAllFiles()
                    }
                }
                .padding()
                Button("Remove All Files") {
                    Task {
                        removeAllFiles()
                    }
                }
                .padding()
            }
            .navigationTitle("Files in Documents")
            .onAppear {
                Task {
                    await loadFiles()
                }
            }
            .onChange(of: restaurantData.restaurant_id) { newID in
                if !newID.isEmpty && !hasFetchedModels {
                    Task {
                        await loadFiles()
                        removeAllFiles()
                        let keys = await fetchModelKeysFromAPI()
                        await asyncDownload(keys: keys)
                        await loadFiles()
                        hasFetchedModels = true
                    }
                }
            }

        }
    }
    
    // This function first runs s3testing() then reloads the file list from the Documents directory.
    func loadFiles() async {
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let files = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)
                await MainActor.run {
                    self.fileNames = files
                }
            } catch {
                print("Error loading files: \(error.localizedDescription)")
            }
        }
    }
    
    func removeFiles() {
        let fileManager = FileManager.default
        
        // Locate the Documents directory.
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Specify the file name you want to remove.
            let fileURL = documentsURL.appendingPathComponent("A7D65F03-0A7D-4B14-8B68-3A068EEB55D5.usdz")
            
            // Optionally, check if the file exists before trying to remove it.
            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    try fileManager.removeItem(at: fileURL)
                    print("File removed successfully.")
                } catch {
                    print("Error removing file: \(error.localizedDescription)")
                }
            } else {
                print("File does not exist.")
            }
        }
    }
    
    func removeAllFiles() {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let files = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                for file in files {
                    try fileManager.removeItem(at: file)
                    print("Removed: \(file.lastPathComponent)")
                }
                Task { await loadFiles() } // Refresh UI file list
            } catch {
                print("Failed to remove files: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchModelKeysFromAPI() async -> [String] {
        guard !restaurantData.restaurant_id.isEmpty else {
            print("restaurant_id is not set")
            return []
        }

        guard let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/restaurant/\(restaurantData.restaurant_id)/models") else {
            print("Invalid URL")
            return []
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let models = json["models"] as? [[String: Any]] {
                return models.compactMap { model in
                    if let modelID = model["model_id"] as? String, !modelID.trimmingCharacters(in: .whitespaces).isEmpty {
                        return "\(modelID).usdz"
                    }
                    return nil
                }
            }
        } catch {
            print("Failed to fetch or parse model IDs: \(error)")
        }

        return []
    }
    
    func asyncDownload(keys: [String]) async {
        do {
            let env = ProcessInfo.processInfo.environment
            let credentials = AWSCredentialIdentity(
                accessKey: env["AWS_ACCESS_KEY"] ?? "NULL",
                secret: env["AWS_SECRET_KEY"] ?? "NULL"
            )
            let identityResolver = try StaticAWSCredentialIdentityResolver(credentials)
            
            let s3Configuration = try await S3Client.S3ClientConfiguration(
                awsCredentialIdentityResolver: identityResolver,
                region: "us-east-1"
            )
            let s3Client = S3Client(config: s3Configuration)
            let serviceHandler = ServiceHandler(client: s3Client)
            
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Could not find documents directory")
                return
            }
            
            try await withTaskGroup(of: Void.self) { group in
                for key in keys {
                    group.addTask {
                        do {
                            print("⬇️ Downloading: \(key)")
                            try await serviceHandler.downloadFile(
                                bucket: "usdz-store-test",
                                key: key,
                                to: documentsDirectory.path
                            )
                            print("Finished: \(key)")
                        } catch {
                            print("Error downloading \(key): \(error)")
                        }
                    }
                }
            }
            
            await loadFiles()
        } catch {
            print("Error setting up AWS download: \(error)")
        }
    }
    
    // s3testing() is responsible for the S3 operations.
    func s3testing(modelPath: URL) async {
        
        do {
            //            let transferUtility = AWSS3TransferUtility.default()
            // Setup AWS credentials (replace with your own or use a secure method).
            let env = ProcessInfo.processInfo.environment
            let credentials = AWSCredentialIdentity(
                accessKey: env["AWS_ACCESS_KEY"] ?? "NULL",
                secret: env["AWS_SECRET_KEY"] ?? "NULL"
            )
            let identityResolver = try StaticAWSCredentialIdentityResolver(credentials)
            
            // Configure the S3 client.
            let s3Configuration = try await S3Client.S3ClientConfiguration(
                awsCredentialIdentityResolver: identityResolver,
                region: "us-east-1"
            )
            let s3Client = S3Client(config: s3Configuration )
            
            // Instantiate ServiceHandler with the S3 client.
            let serviceHandler = ServiceHandler(client: s3Client)
            
            // List buckets (example call).
            let buckets = try await serviceHandler.listBuckets()
            print("Buckets available:", buckets)
            // Download a file from S3 to the Documents directory.
            //            let fileManager = FileManager.default
            //            if let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            //                let documentsDirectoryPath = documentsDirectoryURL.path
            //                try await serviceHandler.downloadFile(bucket: "usdz-store-test", key: "pancakes.usdz", to: documentsDirectoryPath)
            //            }
            //            // testing: upload
            //            if let fileURL = Bundle.main.url(forResource: "apple_1", withExtension: "usdz") {                try await serviceHandler.uploadFile(bucket: "usdz-store-test", key: "apple_1.usdz", file: fileURL.path)
            //            } else {
            //                print("File not found.")
            //            }
            let uuid = UUID().uuidString
            try await serviceHandler.uploadFile(bucket: "usdz-store-test", key: "\(uuid).usdz", file: modelPath.path)
        } catch {
            print("Error occurred in s3testing: \(error)")
        }
        
    }
}
