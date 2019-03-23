import UIKit
import CoreML
import Vision
import NotificationBannerSwift

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        tryAgainButton?.isHidden = true
        
        displayActionSheet(self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage into CIImage")
            }
            
            let title: String = detect(image: ciimage)
            let banner = NotificationBanner(title: title, style: .success)
            banner.show(bannerPosition: .bottom)
            tryAgainButton.isHidden = false
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) -> String {
        
        var title = String()
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model failed !!")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process request")
            }
            
            if let firstResult = results.first {
                title = (firstResult.identifier as? String)!
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
        return title
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func displayActionSheet(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Choose an image source", message: nil, preferredStyle: .actionSheet)
        
        let exitAction = UIAlertAction(title: "Exit", style: .destructive) { ACTION in
            actionSheet.dismiss(animated: true)
            exit(0)
        }
        let exitIcon = UIImage(named: "exit")
        exitAction.setValue(exitIcon, forKey: "image")
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { ACTION in
            actionSheet.dismiss(animated: true)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { ACTION in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cameraIcon = UIImage(named: "camera")
        cameraAction.setValue(cameraIcon, forKey: "image")
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { ACTION in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let libraryIcon = UIImage(named: "gallery")
        libraryAction.setValue(libraryIcon, forKey: "image")
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(exitAction)
        actionSheet.addAction(cancelAction)

        DispatchQueue.main.async {
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    @IBAction func tryAgain(_ sender: Any) {
        imageView.image = nil
        navigationItem.title = nil
        tryAgainButton.isHidden = true
        displayActionSheet(UIButton())
    }
}

extension ViewController : NotificationBannerDelegate {
    func notificationBannerWillAppear(_ banner: BaseNotificationBanner) {
        
    }
    
    func notificationBannerDidAppear(_ banner: BaseNotificationBanner) {
        
    }
    
    func notificationBannerWillDisappear(_ banner: BaseNotificationBanner) {
        
        
    }
    
    func notificationBannerDidDisappear(_ banner: BaseNotificationBanner) {
        
    }
}

