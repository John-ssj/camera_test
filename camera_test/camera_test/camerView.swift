//
//  camerView.swift
//  camera_test
//
//  Created by 史圣久 on 2020/8/6.
//  Copyright © 2020 史圣久. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class camerView: UIViewController, AVCapturePhotoCaptureDelegate {
    lazy var captureDevice: AVCaptureDevice? = {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        return device
    }()
    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession.init()
        return session
    }()
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer.init(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        preview.connection?.videoOrientation = .portrait
        return preview
    }()
    lazy var photoOutput: AVCapturePhotoOutput = {
        let output = AVCapturePhotoOutput.init()
        return output
    }()
    
    var previewView = UIView()
    var floatingView = UIView()
    var captureImageView = UIImageView()
    var falshButton = UIButton()
    var takePicture = UIButton()
    var nextPicture = UIButton()
    
    fileprivate var isFlashOn: Bool = false
    var picture_num: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setUpCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (captureSession.isRunning == false) {
            captureSession.startRunning()
            focusAtPoint(point: CGPoint(x: 10, y: 10))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    private func setUpView() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(previewView)
        previewView.backgroundColor = UIColor.black
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        previewView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        previewView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(focusGesture(gesture:))))
        
        
        // 蒙层
        let Path_inSide: UIBezierPath = UIBezierPath(roundedRect: CGRect(x: 30, y: 80, width: view.bounds.width - 60, height: view.bounds.height - 260), cornerRadius: 10)
        let path_outSide: UIBezierPath = UIBezierPath.init(rect: view.bounds)
        path_outSide.append(Path_inSide)  //合并内外层框架
        path_outSide.usesEvenOddFillRule = true
        // 设置框架颜色并加入floatingView.layer
        let fillLayer = CAShapeLayer()
        fillLayer.path = path_outSide.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.6
        floatingView.layer.addSublayer(fillLayer)
        
        
        view.addSubview(captureImageView)
        captureImageView.translatesAutoresizingMaskIntoConstraints = false
        captureImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        captureImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        captureImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        captureImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        captureImageView.contentMode = .scaleAspectFill
        captureImageView.clipsToBounds = true
        captureImageView.isHidden = true
        
        view.addSubview(takePicture)
        takePicture.translatesAutoresizingMaskIntoConstraints = false
        takePicture.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        takePicture.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        takePicture.widthAnchor.constraint(equalToConstant: 75).isActive = true
        takePicture.heightAnchor.constraint(equalToConstant: 75).isActive = true
        takePicture.setBackgroundImage(UIImage(systemName: "largecircle.fill.circle")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        takePicture.addTarget(self, action: #selector(TakePhoto), for: .touchDown)
        
        view.addSubview(falshButton)
        falshButton.translatesAutoresizingMaskIntoConstraints = false
        falshButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        falshButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        falshButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        falshButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        falshButton.setBackgroundImage(UIImage(systemName: "bolt.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        falshButton.addTarget(self, action: #selector(flashChange), for: .touchDown)
        
        view.addSubview(nextPicture)
        nextPicture.translatesAutoresizingMaskIntoConstraints = false
        nextPicture.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        nextPicture.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        nextPicture.widthAnchor.constraint(equalToConstant: 60).isActive = true
        nextPicture.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nextPicture.setTitle("完成", for: .normal)
        nextPicture.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        nextPicture.setTitleColor(.white, for: .normal)
        nextPicture.setTitleShadowColor(.black, for: .normal)
        nextPicture.addTarget(self, action: #selector(NextPhoto), for: .touchDown)
        nextPicture.isHidden = true
    }
    
    private func setUpCamera() {
        captureSession.sessionPreset = .high
        if let device = captureDevice {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                photoOutput = AVCapturePhotoOutput()
                if captureSession.canAddInput(input) && captureSession.canAddOutput(photoOutput) {
                    captureSession.addInput(input)
                    captureSession.addOutput(photoOutput)
                    
                    previewView.layer.addSublayer(previewLayer)
                    //增加蒙层
                    previewView.addSubview(floatingView)
                    DispatchQueue.global(qos: .userInitiated).async { // [weak self] in
                        self.captureSession.startRunning()
                        DispatchQueue.main.async {
                            self.previewLayer.frame = self.previewView.bounds
                        }
                    }
                }
            } catch let error {
                print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            }
        }
    }

    
    //拍照按钮
    @objc func TakePhoto(btn : UIButton) {
        if !captureSession.isRunning { return }
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    //闪光灯按钮
    @objc private func flashChange(btn : UIButton) {
        if let device = captureDevice {
            if device.hasTorch {
                do { // 请求独占访问硬件设备
                    try device.lockForConfiguration()
                    if (isFlashOn == false) {
                        device.torchMode = AVCaptureDevice.TorchMode.on
                        isFlashOn = true
                        focusAtPoint(point: CGPoint(x: 10, y: 10))
                    } else {
                        device.torchMode = AVCaptureDevice.TorchMode.off
                        isFlashOn = false
                    } // 请求解除独占访问硬件设备
                    device.unlockForConfiguration()
                } catch let error as NSError {
                    print("TorchError  \(error)")
                }
            }else{
                let alert = UIAlertController.init(title: "提示", message: "您的设备没有闪光设备，不能提供手电筒功能，请检查", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: false, completion: nil)
            }
        }
    }
    
    //next按钮
    @objc func NextPhoto(btn : UIButton) {
        if captureSession.isRunning { return }
        
        captureSession.startRunning()
        self.picture_num += 1
        
        previewView.isHidden = false
        takePicture.isHidden = false
        falshButton.isHidden = false
        captureImageView.isHidden = true
        nextPicture.isHidden = true
        
    }
    
    //在一点聚焦
    @objc private func focusAtPoint(point : CGPoint) {
        let size = view.bounds.size
        let focusPoint = CGPoint.init(x: point.y/size.height, y: 1-point.x/size.width)
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }
                // exposure
                if device.isExposureModeSupported(AVCaptureDevice.ExposureMode.autoExpose){
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = .autoExpose
                }
                device.unlockForConfiguration()
            } catch let error {
                print(error)
            }
        }
    }
    
    //点击聚焦
    @objc private func focusGesture(gesture : UITapGestureRecognizer) {
        let point = gesture.location(in: gesture.view)
        focusAtPoint(point: point)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation()
            else {
                print("error")
                return }
        
        captureSession.stopRunning()
        let image = UIImage(data: imageData)
        captureImageView.image = image
        previewView.isHidden = true
        takePicture.isHidden = true
        falshButton.isHidden = true
        captureImageView.isHidden = false
        nextPicture.isHidden = false
        
        if isFlashOn {
            isFlashOn = false
            focusAtPoint(point: CGPoint(x: 10, y: 10))
        }
        
        if let imageData = image!.jpegData(compressionQuality: 1) as NSData? {
            let fullPath = NSHomeDirectory().appending("/Documents/").appending("image_\(picture_num)")
            DispatchQueue.global().async {
                imageData.write(toFile: fullPath, atomically: true)
                print("fullPath=\(fullPath)")
            }
        }
    }
}

func isCanUseCamera() -> Bool {
    let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    if authStatus == .restricted || authStatus == .denied {
        let alert = UIAlertController.init(title: "请打开相机权限", message: "请到设置中去允许应用访问您的相机: 设置-隐私-相机", preferredStyle: UIAlertController.Style.alert)
        print("弹窗")
        let cancelAction = UIAlertAction.init(title: "不需要", style: UIAlertAction.Style.cancel, handler: nil)
        let okAction = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default) { (action) in
            let setUrl = URL.init(string: UIApplication.openSettingsURLString)
            if let url = setUrl, UIApplication.shared.canOpenURL(url) == true {
                UIApplication.shared.open(url)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        let rootVC = UIApplication.shared.windows[0].rootViewController
        rootVC?.present(alert, animated: false, completion: nil)
        return false
        
    } else {
        return true
    }
}
