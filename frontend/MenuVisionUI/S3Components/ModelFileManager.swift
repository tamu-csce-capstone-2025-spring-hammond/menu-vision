//
//  ModelFileManager.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 4/1/25.
//

import Foundation
import AWSS3
import AWSClientRuntime
import AWSSDKIdentity

class ModelFileManager {
    static let shared = ModelFileManager()

    private init() {}

    func clearAndDownloadFiles(for restaurantID: String) async {
        print("Clearing and downloading for restaurant: \(restaurantID)")
        await removeAllFiles()
        let keys = await fetchModelKeysFromAPI(restaurantID: restaurantID)
        if keys.isEmpty {
            print("No models found for restaurant \(restaurantID)")
            return
        }
        await asyncDownload(keys: keys)
    }

    func removeAllFiles() async {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let files = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                for file in files {
                    try fileManager.removeItem(at: file)
                    print("Removed: \(file.lastPathComponent)")
                }
            } catch {
                print("Failed to remove files: \(error.localizedDescription)")
            }
        }
    }

    func fetchModelKeysFromAPI(restaurantID: String) async -> [String] {
        guard !restaurantID.isEmpty,
              let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/restaurant/\(restaurantID)/models")
        else {
            print("Invalid or empty restaurant ID")
            return []
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let models = json["models"] as? [[String: Any]] {
                return models.compactMap { model in
                    if let modelID = model["model_id"] as? String,
                       !modelID.trimmingCharacters(in: .whitespaces).isEmpty {
                        return "\(modelID).usdz"
                    }
                    return nil
                }
            }
        } catch {
            print("Error fetching/parsing models: \(error)")
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

            let s3Config = try await S3Client.S3ClientConfiguration(
                awsCredentialIdentityResolver: identityResolver,
                region: "us-east-1"
            )

            let s3Client = S3Client(config: s3Config)
            let serviceHandler = ServiceHandler(client: s3Client)

            guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Documents directory not found")
                return
            }

            try await withTaskGroup(of: Void.self) { group in
                for key in keys {
                    group.addTask {
                        do {
                            print("Downloading: \(key)")
                            try await serviceHandler.downloadFile(bucket: "usdz-store-test", key: key, to: documentsDir.path)
                            print("Finished: \(key)")
                        } catch {
                            print("Error downloading \(key): \(error)")
                        }
                    }
                }
            }
        } catch {
            print("Error configuring AWS: \(error)")
        }
    }
}
