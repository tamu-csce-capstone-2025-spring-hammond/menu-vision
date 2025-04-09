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

struct TestingView: View {
    @State private var fileNames: [String] = []
    @State private var objects: [String] = []
    var body: some View {
        NavigationView {
            VStack {
                List(fileNames, id: \.self) { fileName in
                    Text(fileName)
                }
                Button("load Files") {
                    Task {
                        await s3testing()
                    }
                }
                .padding()
                Button("View Files") {
                    Task {
                        await loadFiles()
                    }
                }
                .padding()
                Button("Delete Files") {
                    Task {
                        await deleteFile(fileName: "texgen_0.png")
                    }
                }
                .padding()
            }
            .navigationTitle("Files in Documents")
//             Initial load of files when the view appears.
//            .task {
//                await loadFiles()
//            }
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
    
    func deleteFile(fileName: String) async {
            let fileManager = FileManager.default
            if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                do {
                    try fileManager.removeItem(at: fileURL)
                    print("Successfully deleted: \(fileName)")
                } catch {
                    print("Error deleting file \(fileName): \(error.localizedDescription)")
                }
            }
        }
    
    // s3testing() is responsible for the S3 operations.
    func s3testing() async {
        
        do {
//            let transferUtility = AWSS3TransferUtility.default()
            // Setup AWS credentials (replace with your own or use a secure method).
            let accessKey = UserDefaults.standard.string(forKey: "AWS_ACCESS_KEY")
            let secretKey = UserDefaults.standard.string(forKey: "AWS_SECRET_KEY")
            print(accessKey)
            print(secretKey)
            let credentials = AWSCredentialIdentity(
                accessKey: accessKey ?? "NULL",
                secret: secretKey ?? "NULL"
            )
            let identityResolver = try StaticAWSCredentialIdentityResolver(credentials)
            
            // Configure the S3 client.
            let s3Configuration = try await S3Client.S3ClientConfiguration(
                awsCredentialIdentityResolver: identityResolver,
                region: "us-east-1"
            )
            let s3Client = S3Client(config: s3Configuration)
            
            // Instantiate ServiceHandler with the S3 client.
            let serviceHandler = ServiceHandler(client: s3Client)
           
            // List buckets (example call).
            let buckets = try await serviceHandler.listBuckets()
            print("Buckets available:", buckets)
            // Download a file from S3 to the Documents directory.
            
            let fileManager = FileManager.default
            if let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let documentsDirectoryPath = documentsDirectoryURL.path
                try await serviceHandler.downloadFile(bucket: "usdz-store-test", key: "texgen_0.png", to: documentsDirectoryPath)
            }
            
        } catch {
            print("Error occurred in s3testing: \(error)")
        }
        
    }
}

// Uncomment to enable previews.
struct TestingViewPreview: PreviewProvider {
    static var previews: some View {
        TestingView()
    }
}
