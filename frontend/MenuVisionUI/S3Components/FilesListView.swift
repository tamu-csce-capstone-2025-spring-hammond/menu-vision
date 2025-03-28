////
////  FilesListView.swift
////  Swift_s3_practicing
////
////  Created by Sam Zhou on 3/23/25.
////
//
//import SwiftUI
//import Foundation
//@preconcurrency import AWSS3
//import AWSClientRuntime
//import ClientRuntime
//import AWSSDKIdentity
//
//struct FilesListView: View {
//    @State private var fileNames: [String] = []
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                List(fileNames, id: \.self) { fileName in
//                    Text(fileName)
//                }
//                Button("View Files") {
//                    Task {
//                        await loadFiles()
//                    }
//                }
//                .padding()
//                Button("download Files") {
//                    Task {
////                        await s3testing()
//                    }
//                }
//                .padding()
//                Button("delete Files") {
//                    Task {
//                        removeFiles()
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("Files in Documents")
////             Initial load of files when the view appears.
//            .task {
//                await loadFiles()
//            }
//        }
//    }
//    
//    // This function first runs s3testing() then reloads the file list from the Documents directory.
//    func loadFiles() async {
////        await s3testing()
//        let fileManager = FileManager.default
//        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
//            do {
//                // Retrieve list of files in the documents directory
//                let files = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)
//                self.fileNames = files
//            } catch {
//                print("Error loading files: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func removeFiles() {
//        let fileManager = FileManager.default
//
//        // Locate the Documents directory.
//        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
//            // Specify the file name you want to remove.
//            let fileURL = documentsURL.appendingPathComponent("pancakes.usdz")
//            
//            // Optionally, check if the file exists before trying to remove it.
//            if fileManager.fileExists(atPath: fileURL.path) {
//                do {
//                    try fileManager.removeItem(at: fileURL)
//                    print("File removed successfully.")
//                } catch {
//                    print("Error removing file: \(error.localizedDescription)")
//                }
//            } else {
//                print("File does not exist.")
//            }
//        }
//    }
//    
//    // s3testing() is responsible for the S3 operations.
//    func s3testing(modelPath: URL) async {
//        
//        do {
////            let transferUtility = AWSS3TransferUtility.default()
//            // Setup AWS credentials (replace with your own or use a secure method).
//            let env = ProcessInfo.processInfo.environment
//            let credentials = AWSCredentialIdentity(
//                accessKey: env["AWS_ACCESS_KEY"] ?? "NULL",
//                secret: env["AWS_SECRET_KEY"] ?? "NULL"
//            )
//            let identityResolver = try StaticAWSCredentialIdentityResolver(credentials)
//            
//            // Configure the S3 client.
//            let s3Configuration = try await S3Client.S3ClientConfiguration(
//                awsCredentialIdentityResolver: identityResolver,
//                region: "us-east-1"
//            )
//            let s3Client = S3Client(config: s3Configuration )
//            
//            // Instantiate ServiceHandler with the S3 client.
//            let serviceHandler = ServiceHandler(client: s3Client)
//           
//            // List buckets (example call).
//            let buckets = try await serviceHandler.listBuckets()
//            print("Buckets available:", buckets)
//            // Download a file from S3 to the Documents directory.
////            let fileManager = FileManager.default
////            if let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
////                let documentsDirectoryPath = documentsDirectoryURL.path
////                try await serviceHandler.downloadFile(bucket: "usdz-store-test", key: "pancakes.usdz", to: documentsDirectoryPath)
////            }
////            // testing: upload
////            if let fileURL = Bundle.main.url(forResource: "apple_1", withExtension: "usdz") {                try await serviceHandler.uploadFile(bucket: "usdz-store-test", key: "apple_1.usdz", file: fileURL.path)
////            } else {
////                print("File not found.")
////            }
//            let uuid = UUID().uuidString
//            try await serviceHandler.uploadFile(bucket: "usdz-store-test", key: "\(uuid).usdz", file: modelPath.path)
//        } catch {
//            print("Error occurred in s3testing: \(error)")
//        }
//        
//    }
//    
////    func setupServiceHandler() async throws -> ServiceHandler {
////        // Setup AWS credentials (replace with your own or use a secure method).
////        let env = ProcessInfo.processInfo.environment
////        let credentials = AWSCredentialIdentity(
////            accessKey: env["AWS_ACCESS_KEY"] ?? "NULL",
////            secret: env["AWS_SECRET_KEY"] ?? "NULL"
////        )
////        let identityResolver = try StaticAWSCredentialIdentityResolver(credentials)
////
////        // Configure the S3 client.
////        let s3Configuration = try await S3Client.S3ClientConfiguration(
////            awsCredentialIdentityResolver: identityResolver,
////            region: "us-east-1"
////        )
////        let s3Client = S3Client(config: s3Configuration)
////
////        // Instantiate ServiceHandler with the S3 client.
////        return ServiceHandler(client: s3Client)
////    }
////
////    func uploadFile(serviceHandler: ServiceHandler, modelPath: URL) async throws {
////        // Perform the upload action
////        try await serviceHandler.uploadFile(bucket: "usdz-store-test", key: "model.usdz", file: modelPath.path)
////    }
//}
//
//// Uncomment to enable previews.
//struct FilesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilesListView()
//    }
//}


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
    
    var body: some View {
        NavigationView {
            VStack {
                List(fileNames, id: \.self) { fileName in
                    Text(fileName)
                }
                Button("View Files") {
                    Task {
                        await loadFiles()
                    }
                }
                .padding()
                Button("download Files") {
                    Task {
//                        await s3testing()
                    }
                }
                .padding()
                Button("delete Files") {
                    Task {
                        removeFiles()
                    }
                }
                .padding()
            }
            .navigationTitle("Files in Documents")
//             Initial load of files when the view appears.
            .task {
                await loadFiles()
            }
        }
    }
    
    // This function first runs s3testing() then reloads the file list from the Documents directory.
    func loadFiles() async {
//        await s3testing()
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                // Retrieve list of files in the documents directory
                let files = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)
                self.fileNames = files
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
            let fileURL = documentsURL.appendingPathComponent("pancakes.usdz")
            
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
            let fileExtension = (modelPath.path as NSString).pathExtension
            let key = "\(uuid).\(fileExtension)"
            try await serviceHandler.uploadFile(bucket: "usdz-store-test", key: key, file: modelPath.path)
        } catch {
            print("Error occurred in s3testing: \(error)")
        }
        
    }
    
//    func setupServiceHandler() async throws -> ServiceHandler {
//        // Setup AWS credentials (replace with your own or use a secure method).
//        let env = ProcessInfo.processInfo.environment
//        let credentials = AWSCredentialIdentity(
//            accessKey: env["AWS_ACCESS_KEY"] ?? "NULL",
//            secret: env["AWS_SECRET_KEY"] ?? "NULL"
//        )
//        let identityResolver = try StaticAWSCredentialIdentityResolver(credentials)
//
//        // Configure the S3 client.
//        let s3Configuration = try await S3Client.S3ClientConfiguration(
//            awsCredentialIdentityResolver: identityResolver,
//            region: "us-east-1"
//        )
//        let s3Client = S3Client(config: s3Configuration)
//
//        // Instantiate ServiceHandler with the S3 client.
//        return ServiceHandler(client: s3Client)
//    }
//
//    func uploadFile(serviceHandler: ServiceHandler, modelPath: URL) async throws {
//        // Perform the upload action
//        try await serviceHandler.uploadFile(bucket: "usdz-store-test", key: "model.usdz", file: modelPath.path)
//    }
}

// Uncomment to enable previews.
struct FilesListView_Previews: PreviewProvider {
    static var previews: some View {
        FilesListView()
    }
}
