//
//  ServiceHandler.swift
//  aws-sdk-swift-test
//
//  Created by Sam Zhou on 3/21/25.
//

//
//  ServiceHandler.swift
//  AWS S3 Swift Project
//
//  A class that wraps AWS S3 operations. It now accepts an S3Client instance
//  provided by the caller (from entry.swift).
//
import Swift
import Foundation
import AWSS3
import ClientRuntime
import Smithy
import SmithyHTTPAPI
import SmithyStreams



public class ServiceHandler {
    private let client: S3Client

    /// Initialize the handler with an already configured S3 client.
    public init(client: S3Client) {
        self.client = client
    }
    enum HandlerError: Error {
            case getObjectBody(String)
            case readGetObjectBody(String)
            case missingContents(String)
        }


    /// List all buckets.
    public func listBuckets() async throws -> [String] {
        let input = ListBucketsInput(maxBuckets: 10)
        let pages = client.listBucketsPaginated(input: input)
        var bucketNames: [String] = []
        for try await page in pages {
            if let buckets = page.buckets {
                for bucket in buckets {
                    bucketNames.append(bucket.name ?? "<unknown>")
                }
            }
        }
        return bucketNames
    }

    /// Create a new bucket with the given name.
    public func createBucket(name: String) async throws {
        var input = CreateBucketInput(bucket: name)
        let region = "us-east-1"
        // If the client's region is not "us-east-1", set the location constraint.
        if region != "us-east-1" {
            input.createBucketConfiguration = S3ClientTypes.CreateBucketConfiguration(
                locationConstraint: S3ClientTypes.BucketLocationConstraint(rawValue: region)
            )
        }
        _ = try await client.createBucket(input: input)
    }

    /// Delete a bucket with the given name.
    public func deleteBucket(name: String) async throws {
        let input = DeleteBucketInput(bucket: name)
        _ = try await client.deleteBucket(input: input)
    }

    /// Upload a file from local storage to the bucket.
    /// /// - Parameters:
    ///   - bucket: Name of the bucket to upload the file to.
    ///   - key: Name of the file to create.
    ///   - file: Path name of the file to upload.
    public func uploadFile(bucket: String, key: String, file: String) async throws {
            let fileUrl = URL(fileURLWithPath: file)
            do {
                let fileData = try Data(contentsOf: fileUrl)
                let dataStream = ByteStream.data(fileData)

                let input = PutObjectInput(
                    body: dataStream,
                    bucket: bucket,
                    key: key
                )

                _ = try await client.putObject(input: input)
            }
            catch {
                print("ERROR: ", dump(error, name: "Putting an object."))
                throw error
            }
        }

    /// Download the specified file from a bucket to a local directory.
    public func downloadFile(bucket: String, key: String, to: String) async throws {
        let fileUrl = URL(fileURLWithPath: to).appendingPathComponent(key)

                let input = GetObjectInput(
                    bucket: bucket,
                    key: key
                )
                do {
                    let output = try await client.getObject(input: input)
                   

                    guard let body = output.body else {
                        throw HandlerError.getObjectBody("GetObjectInput missing body.")
                    }
                    print(type(of: body))
                    let getStartTime = Date()
                    guard let data = try await body.readData() else {
                        throw HandlerError.readGetObjectBody("GetObjectInput unable to read data.")
                    }
                    let getEndTime = Date()
                    print("s3 download time took \(getEndTime.timeIntervalSince(getStartTime)) seconds")
                   
                    try data.write(to: fileUrl)
                }
                catch {
                    print("ERROR: ", dump(error, name: "Downloading a file."))
                    throw error
                }
            }
    
    public func listBucketFiles(bucket: String) async throws -> [String] {
        let input = ListObjectsV2Input(bucket: bucket)
        let output = client.listObjectsV2Paginated(input: input)
        var fileNames: [String] = []
        for try await page in output {
            if let objects = page.contents {
                for obj in objects {
                    if let key = obj.key {
                        fileNames.append(key)
                    }
                }
            }
        }
        return fileNames
    }
}

    /// List all file names in a bucket.
    

