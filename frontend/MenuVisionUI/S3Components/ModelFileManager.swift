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

    func clearAndDownloadFiles(for restaurantID: String) async -> [DishData] {
        print("Clearing and downloading for restaurant: \(restaurantID)")
        await removeAllFiles()

        let (keys, models) = await fetchModelKeysAndModelsFromAPI(restaurantID: restaurantID)
        if keys.isEmpty {
            return []
        }

        await asyncDownload(keys: keys)
        return models
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

    func fetchModelKeysAndModelsFromAPI(restaurantID: String) async -> ([String], [DishData]) {
        guard let url = URL(string: "http://127.0.0.1:8080/ar/restaurant/\(restaurantID)/models") else {
            return ([], [])
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(DishDataResponse.self, from: data)

            let validModels = response.models.filter {
                !$0.dish_name.isEmpty && !$0.model_id.isEmpty
            }

            let keys = validModels.map { "\($0.model_id).usdz" }
            return (keys, validModels)

        } catch {
            print("No model data found for restaurant: \(restaurantID)")
            return ([], [])
        }
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
    
    func listAllFilesInDocumentsDirectory() {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let files = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                print("\nFiles in Documents directory:")
                for file in files {
                    print("- \(file.lastPathComponent)")
                }
            } catch {
                print("Failed to list files: \(error.localizedDescription)")
            }
        }
    }
}
