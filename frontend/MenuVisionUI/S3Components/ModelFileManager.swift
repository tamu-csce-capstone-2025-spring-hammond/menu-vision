//
//  ModelFileManager.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 4/1/25.
//
import SwiftUI
import Foundation
import AWSS3
import AWSClientRuntime
import AWSSDKIdentity

class ModelFileManager {
    static let shared = ModelFileManager()
//    @EnvironmentObject var dishMapping: DishMapping

    private init() {}

    func clearAndDownloadFiles(for restaurantID: String, dishMapping: DishMapping) async -> [DishData] {
        print("Clearing and downloading for restaurant: \(restaurantID)")
        await removeAllFiles()
        dishMapping.totalModels = 0
        dishMapping.modelCount = 0

        let (keys, models) = await fetchModelKeysAndModelsFromAPI(restaurantID: restaurantID)
        
        if keys.isEmpty {
            return []
        }
        dishMapping.totalModels = keys.count
        print("dishMapping.totalModels", dishMapping.totalModels)
        await asyncDownload(keys: keys, dishMapping: dishMapping)
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
        guard let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/restaurant/\(restaurantID)/models") else {
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


    func asyncDownload(keys: [String], dishMapping: DishMapping) async {
        do {
            let accessKey = UserDefaults.standard.string(forKey: "AWS_ACCESS_KEY")
            let secretKey = UserDefaults.standard.string(forKey: "AWS_SECRET_KEY")
                    
            let credentials = AWSCredentialIdentity(
                accessKey: accessKey ?? "NULL",
                secret: secretKey ?? "NULL"
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
                            dishMapping.modelCount += 1
                            print("dishMapping.modelCount", dishMapping.modelCount)
                        } catch {
                            print("Error downloading \(key): \(error)")
                        }
                    }
                    
                    let pngKey = key.replacingOccurrences(of: ".usdz", with: ".png")
                    group.addTask {
                        do {
                            print("Downloading: \(pngKey)")
                            try await serviceHandler.downloadFile(bucket: "usdz-store-test", key: pngKey, to: documentsDir.path)
                            print("Finished: \(pngKey)")
                            
                        } catch {
                            print("Error downloading \(pngKey): \(error)")
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
