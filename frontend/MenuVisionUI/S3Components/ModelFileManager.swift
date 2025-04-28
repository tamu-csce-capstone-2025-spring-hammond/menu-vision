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

/// A singleton class that manages 3D model files, including downloading, storage, and cleanup.
///
/// This class handles the transfer of 3D model files between AWS S3 storage and the local
/// device filesystem. It provides methods to download all models for a restaurant and
/// clear local storage when needed.
class ModelFileManager {
    /// The shared singleton instance of ModelFileManager.
    static let shared = ModelFileManager()

    /// Private initializer to ensure singleton pattern.
    private init() {}

    /// Clears all local files and downloads model files for a specific restaurant.
    ///
    /// This method removes all previously downloaded files from the documents directory
    /// and then downloads all models associated with the specified restaurant from S3.
    ///
    /// - Parameters:
    ///   - restaurantID: The unique identifier of the restaurant.
    ///   - dishMapping: The DishMapping instance to update with download progress.
    /// - Returns: An array of DishData objects representing the downloaded models.
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

    /// Removes all files from the app's documents directory.
    ///
    /// This method is used to clean up local storage before downloading new model files.
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

    /// Fetches model keys and data from the API for a specific restaurant.
    ///
    /// - Parameter restaurantID: The unique identifier of the restaurant.
    /// - Returns: A tuple containing (1) an array of model keys for download from S3
    ///           and (2) an array of DishData objects with the model metadata.
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

    /// Asynchronously downloads multiple files from S3 to local storage.
    ///
    /// This method configures AWS credentials and downloads both the USDZ model files
    /// and their associated PNG thumbnails.
    ///
    /// - Parameters:
    ///   - keys: An array of file keys to download from S3.
    ///   - dishMapping: The DishMapping instance to update with download progress.
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
    
    /// Lists all files in the app's documents directory.
    ///
    /// This is a diagnostic method used to verify what files are currently stored locally.
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
