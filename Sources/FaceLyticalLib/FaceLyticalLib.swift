import SwiftUI
import AVFoundation

/// FaceLytical is the main entry point for the face detection and capture library.
public struct FaceLyticalLib {
    
    /// Initializes a new instance of the FaceLytical library.
    public init() {}
    
    /// Presents the face detection and capture view.
    /// - Parameters:
    ///   - from: The view controller from which to present the face detection view.
    ///   - completion: Callback that receives the captured face image. Nil if user cancels.
    public func presentFaceDetection(from viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        let hostingController = UIHostingController(
            rootView: FaceDetectionView { image in
                completion(image)
            }
        )
        hostingController.modalPresentationStyle = .fullScreen
        viewController.present(hostingController, animated: true)
    }
    
    /// Creates a SwiftUI view that can be embedded in a SwiftUI view hierarchy.
    /// - Parameter onCapture: Callback that receives the captured face image.
    /// - Returns: A SwiftUI view that handles face detection and capture.
    public func createFaceDetectionView(onCapture: @escaping (UIImage) -> Void) -> some View {
        FaceDetectionView(onCapture: onCapture)
    }
    
    /// Checks if the camera permission is granted.
    /// - Returns: Boolean indicating if camera permission is granted.
    public static func hasCameraPermission() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    /// Requests camera permission if not already granted.
    /// - Parameter completion: Callback that receives a boolean indicating if permission was granted.
    public static func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                completion(true)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            default:
                completion(false)
        }
    }
    
    /// Converts a UIImage to a base64 encoded string.
    /// - Parameters:
    ///   - image: The UIImage to convert.
    ///   - compressionQuality: JPEG compression quality (0.0 to 1.0) where 1.0 is maximum quality.
    /// - Returns: A base64 encoded string representation of the image, or nil if conversion fails.
    public static func convertImageToBase64(_ image: UIImage, compressionQuality: CGFloat = 0.8) -> String? {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
    
    /// Presents the face detection view and returns the captured image as a base64 string.
    /// - Parameters:
    ///   - from: The view controller from which to present the face detection view.
    ///   - compressionQuality: JPEG compression quality (0.0 to 1.0) where 1.0 is maximum quality.
    ///   - completion: Callback that receives the base64 encoded image string. Nil if user cancels or conversion fails.
    public func presentFaceDetectionForBase64(from viewController: UIViewController,
                                              compressionQuality: CGFloat = 0.8,
                                              completion: @escaping (String?) -> Void) {
        presentFaceDetection(from: viewController) { image in
            guard let capturedImage = image else {
                completion(nil)
                return
            }
            
            let base64String = FaceLyticalLib.convertImageToBase64(capturedImage,
                                                                   compressionQuality: compressionQuality)
            completion(base64String)
        }
    }
}
