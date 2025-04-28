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

/// A service handler class that manages AWS S3 operations for the application.
///
/// This class provides methods for interacting with Amazon S3 storage services,
/// allowing the app to list buckets, create or delete buckets, and upload or
/// download files to and from S3 storage.
public class ServiceHandler {
    /// The S3 client instance used to communicate with AWS S3 services.
    private let client: S3Client

    /// Initialize the handler with an already configured S3 client.
    ///
    /// - Parameter client: A pre-configured S3Client instance.
    public init(client: S3Client) {
        self.client = client
    }
    
    /// Possible errors that can occur during S3 operations.
    enum HandlerError: Error {
        /// Error getting object body from S3.
        case getObjectBody(String)
        /// Error reading the object body data.
        case readGetObjectBody(String)
        /// Error when expected contents are missing.
        case missingContents(String)
    }

    /// Lists all available S3 buckets.
    ///
    /// - Returns: An array of bucket names as strings.
    /// - Throws: An error if the operation fails.
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

    /// Creates a new S3 bucket with the specified name.
    ///
    /// - Parameter name: The name for the new bucket.
    /// - Throws: An error if the operation fails.
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

    /// Deletes an S3 bucket with the specified name.
    ///
    /// - Parameter name: The name of the bucket to delete.
    /// - Throws: An error if the operation fails.
    public func deleteBucket(name: String) async throws {
        let input = DeleteBucketInput(bucket: name)
        _ = try await client.deleteBucket(input: input)
    }

    /// Uploads a file from local storage to an S3 bucket.
    ///
    /// - Parameters:
    ///   - bucket: Name of the bucket to upload the file to.
    ///   - key: Name of the file to create in S3.
    ///   - file: Local path of the file to upload.
    /// - Throws: An error if the upload operation fails.
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

    /// Downloads a file from an S3 bucket to a local directory.
    ///
    /// - Parameters:
    ///   - bucket: Name of the bucket containing the file.
    ///   - key: Name of the file to download.
    ///   - to: Local directory path where the file should be saved.
    /// - Throws: An error if the download operation fails.
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
    
    /// Lists all files in a specific S3 bucket.
    ///
    /// - Parameter bucket: The name of the bucket to list files from.
    /// - Returns: An array of filenames (keys) in the bucket.
    /// - Throws: An error if the operation fails.
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
