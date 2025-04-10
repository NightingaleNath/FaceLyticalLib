# FaceLyticalLib

A professional face detection and capture library for iOS applications. FaceLyticalLib provides an easy-to-integrate solution for detecting and capturing face images with real-time feedback.

## Features

- 📱 Real-time face detection using Vision framework
- 🔍 Visual feedback when a face is detected
- 📷 Automatic image capture of detected faces
- 🎯 Corner guides to help users position their face
- 👨‍🏫 Built-in tutorial walkthrough for users
- 🔄 Support for both UIKit and SwiftUI integration
- 📊 Base64 image conversion for network/storage use cases

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 14.0+

## Installation

### Swift Package Manager

#### When using tagged versions:

Add the package dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/NightingaleNath/FaceLyticalLib.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File > Add Packages...
2. Enter the repository URL: `https://github.com/NightingaleNath/FaceLyticalLib.git`
3. Choose "Up to Next Major Version" with "1.0.0" as the version

#### Using the main branch (latest development version):

```swift
dependencies: [
    .package(url: "https://github.com/NightingaleNath/FaceLyticalLib.git", branch: "main")
]
```

Or in Xcode:
1. File > Add Packages...
2. Enter the repository URL: `https://github.com/NightingaleNath/FaceLyticalLib.git`
3. In "Dependency Rule" dropdown, select "Branch" and choose "main"

### Manual Installation

If you prefer not to use Swift Package Manager, you can add the library manually:

1. Download or clone the repository
2. Drag and drop the `Sources/FaceLyticalLib` directory into your Xcode project
3. Make sure "Copy items if needed" is selected and add to your target

## Usage

Don't forget to add the camera usage description to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to detect and capture your face.</string>
```

### SwiftUI Implementation

Here's a complete example of how to implement face detection in a SwiftUI app:

```swift
import SwiftUI
import FaceLyticalLib

class ViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isFaceCaptured: Bool = false
    
    func handleCapturedFace(image: UIImage) {
        self.capturedImage = image
        self.isFaceCaptured = true
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var showingFaceDetection = false
    
    // Create an instance of FaceLytical
    private let faceLytical = FaceLytical()
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.07, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Face Scanner")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Camera preview container
                GeometryReader { geometry in
                    let previewWidth = geometry.size.width - 40 // Accounting for horizontal padding
                    
                    ZStack {
                        // Border
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: previewWidth, height: previewWidth)
                        
                        if let image = viewModel.capturedImage {
                            // Show captured image
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: previewWidth, height: previewWidth)
                                .clipped()
                        } else {
                            // Show placeholder
                            Rectangle()
                                .fill(Color(white: 0.15))
                                .frame(width: previewWidth, height: previewWidth)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray)
                                        .frame(width: 100, height: 100)
                                )
                            
                            // Add corner guides
                            CornerGuidesView(frameSize: previewWidth)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 20)
                
                Text(viewModel.isFaceCaptured ? "Face scan complete" : "Scan your face to continue")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Camera button
                Button {
                    showingFaceDetection = true
                } label: {
                    Image(systemName: viewModel.isFaceCaptured ? "arrow.clockwise" : "camera.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .frame(width: 70, height: 70)
                        .background(viewModel.isFaceCaptured ? Color.green : Color.blue)
                        .clipShape(Circle())
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showingFaceDetection) {
            // Pass a closure for handling captured images
            faceLytical.createFaceDetectionView(onCapture: { image in
                viewModel.handleCapturedFace(image: image)
            })
        }
    }
}
```

### UIKit Implementation

Here's how to implement the face detection in a UIKit-based app:

```swift
import UIKit
import FaceLyticalLib

class ViewController: UIViewController {
    
    // UI elements
    private let titleLabel = UILabel()
    private let previewContainer = UIView()
    private let previewBorder = UIView()
    private let placeholderImageView = UIImageView()
    private let capturedImageView = UIImageView()
    private let statusLabel = UILabel()
    private let cameraButton = UIButton()
    
    // Face detection library
    private let faceLytical = FaceLytical()
    
    // State tracking
    private var isFaceCaptured = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Set background color
        view.backgroundColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0)
        
        // Title label
        titleLabel.text = "Face Scanner"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Preview container
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewContainer)
        
        // Preview border
        previewBorder.translatesAutoresizingMaskIntoConstraints = false
        previewBorder.layer.borderWidth = 2
        previewBorder.layer.borderColor = UIColor.white.cgColor
        previewContainer.addSubview(previewBorder)
        
        // Placeholder image view
        placeholderImageView.image = UIImage(systemName: "person.fill")
        placeholderImageView.contentMode = .scaleAspectFit
        placeholderImageView.tintColor = .gray
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        previewBorder.addSubview(placeholderImageView)
        
        // Add corner guides (this would be a UIView subclass that draws the corner guides)
        let cornerGuides = UIHostingController(rootView: CornerGuidesView())
        cornerGuides.view.translatesAutoresizingMaskIntoConstraints = false
        cornerGuides.view.backgroundColor = .clear
        previewBorder.addSubview(cornerGuides.view)
        
        // Captured image view (initially hidden)
        capturedImageView.contentMode = .scaleAspectFill
        capturedImageView.clipsToBounds = true
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        capturedImageView.isHidden = true
        previewBorder.addSubview(capturedImageView)
        
        // Status label
        statusLabel.text = "Scan your face to continue"
        statusLabel.textColor = .white
        statusLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Camera button
        cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        cameraButton.tintColor = .white
        cameraButton.backgroundColor = .blue
        cameraButton.layer.cornerRadius = 35 // Half of the height to make it circular
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Preview container
            previewContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            previewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            previewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            previewContainer.heightAnchor.constraint(equalTo: previewContainer.widthAnchor), // Square aspect ratio
            
            // Preview border
            previewBorder.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            previewBorder.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            previewBorder.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),
            previewBorder.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),
            
            // Placeholder image
            placeholderImageView.centerXAnchor.constraint(equalTo: previewBorder.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: previewBorder.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 100),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Corner guides
            cornerGuides.view.topAnchor.constraint(equalTo: previewBorder.topAnchor),
            cornerGuides.view.leadingAnchor.constraint(equalTo: previewBorder.leadingAnchor),
            cornerGuides.view.trailingAnchor.constraint(equalTo: previewBorder.trailingAnchor),
            cornerGuides.view.bottomAnchor.constraint(equalTo: previewBorder.bottomAnchor),
            
            // Captured image view
            capturedImageView.topAnchor.constraint(equalTo: previewBorder.topAnchor),
            capturedImageView.leadingAnchor.constraint(equalTo: previewBorder.leadingAnchor),
            capturedImageView.trailingAnchor.constraint(equalTo: previewBorder.trailingAnchor),
            capturedImageView.bottomAnchor.constraint(equalTo: previewBorder.bottomAnchor),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Camera button
            cameraButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 70),
            cameraButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    @objc private func cameraButtonTapped() {
        if isFaceCaptured {
            // Reset to capture a new face
            isFaceCaptured = false
            capturedImageView.isHidden = true
            placeholderImageView.isHidden = false
            statusLabel.text = "Scan your face to continue"
            cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
            cameraButton.backgroundColor = .blue
        } else {
            // Launch face detection
            faceLytical.presentFaceDetection(from: self) { [weak self] image in
                guard let self = self, let capturedImage = image else { return }
                
                // Update UI with captured image
                self.capturedImageView.image = capturedImage
                self.capturedImageView.isHidden = false
                self.placeholderImageView.isHidden = true
                self.statusLabel.text = "Face scan complete"
                self.cameraButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
                self.cameraButton.backgroundColor = .green
                self.isFaceCaptured = true
            }
        }
    }
}
```

## Using Base64 Image Conversion

FaceLyticalLib provides convenient methods for working with base64 image representations:

### SwiftUI - Convert after capture

```swift
// First capture the image
faceLytical.createFaceDetectionView(onCapture: { image in
    // Store the image for display
    viewModel.handleCapturedFace(image: image)
    
    // Convert to base64 if needed for network transmission or storage
    if let base64String = FaceLyticalLib.convertImageToBase64(image) {
        // Use the base64 string (e.g., send to server)
        print("Image as base64: \(base64String.prefix(20))...")
        
        // You could store it in your view model
        // viewModel.imageBase64 = base64String
    }
})
```

### UIKit - Get base64 directly

```swift
// Get base64 string directly, useful for API calls
faceLytical.presentFaceDetectionForBase64(from: viewController) { base64String in
    if let imageString = base64String {
        // Use the base64 string for API calls or storage
        apiService.uploadImage(base64: imageString)
        
        // If you also need the UIImage for display
        if let imageData = Data(base64Encoded: imageString),
           let uiImage = UIImage(data: imageData) {
            // Display the image
            self.imageView.image = uiImage
        }
    }
}
```

## API Reference

### `FaceLytical`

The main entry point for the library.

#### Methods

- `init()`: Initialize a new instance of FaceLytical
- `presentFaceDetection(from:completion:)`: Present the face detection UI from a UIViewController
- `createFaceDetectionView(onCapture:)`: Create a SwiftUI view for face detection
- `static hasCameraPermission() -> Bool`: Check if camera permission is granted
- `static requestCameraPermission(completion:)`: Request camera permission
- `static convertImageToBase64(_ image:compressionQuality:) -> String?`: Convert a UIImage to base64 string
- `presentFaceDetectionForBase64(from:compressionQuality:completion:)`: Present face detection UI and return the captured image as base64 string

### `CameraManager`

Manages camera operations, face detection, and photo capture.

#### Properties

- `currentImage: UIImage?`: The current captured image
- `faceDetected: Bool`: Whether a face is detected in the current frame
- `isCapturing: Bool`: Whether the camera is currently capturing an image
- `captureSession: AVCaptureSession?`: The AVCaptureSession used by the camera

#### Methods

- `setRegionOfInterest(viewFrame:previewFrame:)`: Set the region of interest for face detection
- `checkPermissions()`: Check and request camera permissions
- `setupCaptureSession()`: Set up the camera capture session
- `capturePhoto()`: Capture a photo when a face is detected
- `stopSession()`: Stop the capture session

## Common Issues & Troubleshooting

### Camera Not Working in Simulator

Face detection requires a physical camera, so you'll need to test on a physical device. The simulator does not have full camera capabilities.

### Face Detection Not Working

- Ensure you have good lighting conditions
- Make sure your face is clearly visible and centered
- Check that all camera permissions are granted

### Permissions Issues

If users deny camera permissions, you'll need to guide them to enable permissions in Settings:

```swift
// For Swift
if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
    // Show alert with instructions to open Settings
    let alert = UIAlertController(
        title: "Camera Permission Required",
        message: "Please enable camera access in Settings to use face detection",
        preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    })
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    viewController.present(alert, animated: true)
}
```

## License

FaceLyticalLib is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Credits

Created by [Nathaniel Nkrumah]
