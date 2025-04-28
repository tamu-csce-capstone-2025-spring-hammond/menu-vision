//
//  ARQuickLookView.swift
//  SuperSimpleObjectCapture
//

import SwiftUI
import QuickLook

/// A SwiftUI wrapper view that presents a 3D model in AR Quick Look using `QLPreviewController`.
struct ARQuickLookView: UIViewControllerRepresentable {
    
    /// The URL of the 3D model file to preview.
    let modelFile: URL
    
    /// A callback triggered when the Quick Look preview is dismissed.
    let endCaptureCallback: () -> Void
    
    /// Creates the `QLPreviewControllerWrapper` to present the Quick Look preview.
    /// - Parameter context: The context for coordinating between SwiftUI and UIKit.
    /// - Returns: A `QLPreviewControllerWrapper` instance.
    func makeUIViewController(context: Context) -> QLPreviewControllerWrapper {
        let controller = QLPreviewControllerWrapper()
        controller.previewController.dataSource = context.coordinator
        controller.previewController.delegate = context.coordinator
        return controller
    }
    
    /// Updates the UIKit controller (not used here since Quick Look does not dynamically update).
    /// - Parameters:
    ///   - uiViewController: The view controller instance.
    ///   - context: The context for the view controller.
    func updateUIViewController(_ uiViewController: QLPreviewControllerWrapper, context: Context) {}
    
    /// Creates the coordinator that acts as the data source and delegate for `QLPreviewController`.
    /// - Returns: A `Coordinator` instance.
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    /// Coordinator class that serves as both delegate and data source for Quick Look preview.
    class Coordinator: NSObject, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
        /// The parent `ARQuickLookView`.
        let parent: ARQuickLookView
        
        /// Initializes the coordinator with its parent view.
        /// - Parameter parent: The `ARQuickLookView` that owns this coordinator.
        init(parent: ARQuickLookView) {
            self.parent = parent
        }
        
        /// Returns the number of items to preview.
        /// - Parameter controller: The `QLPreviewController` requesting the item count.
        /// - Returns: The number of preview items (always 1).
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        /// Provides the item to preview.
        /// - Parameters:
        ///   - controller: The `QLPreviewController` requesting the preview item.
        ///   - index: The index of the requested item (always 0).
        /// - Returns: The `modelFile` as a `QLPreviewItem`.
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.modelFile as QLPreviewItem
        }
        
        /// Notifies when the Quick Look controller is about to be dismissed.
        /// - Parameter controller: The `QLPreviewController` being dismissed.
        func previewControllerWillDismiss(_ controller: QLPreviewController) {
            parent.endCaptureCallback()
        }
    }
}

extension ARQuickLookView {
    
    /// A UIKit wrapper around `QLPreviewController` that ensures it is presented once when the view appears.
    class QLPreviewControllerWrapper: UIViewController {
        /// The embedded Quick Look preview controller.
        let previewController = QLPreviewController()
        
        /// A boolean indicating whether the Quick Look preview has been presented.
        var quickLookIsPresented = false
        
        /// Presents the `previewController` once when the view appears.
        /// - Parameter animated: Whether the appearance is animated.
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            if !quickLookIsPresented {
                present(previewController, animated: false)
                quickLookIsPresented = true
            }
        }
    }
}
