//
//  YHYScanningQRCodeViewController.swift
//  LookingForCharging
//
//  Created by 太阳在线YHY on 2017/3/24.
//  Copyright © 2017年 太阳在线. All rights reserved.
//

import UIKit
import AVFoundation


protocol YHYScanningQRCodeViewControllerDelegate: class {
	func getVoucherNum(number: String)
}


class YHYScanningQRCodeViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
	/** 会话对象 */
	
	var session: AVCaptureSession?
	/** 图层类 */
	var previewLayer: AVCaptureVideoPreviewLayer?
	var scanningView: YHYScanningQRCodeView?
	var rightButton: UIButton?
	var isFirstpush: Bool = false
	weak var delegate: YHYScanningQRCodeViewControllerDelegate?
	

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.title = "扫一扫"
		view.backgroundColor = UIColor.white
		
		scanningView = YHYScanningQRCodeView(frame: view.frame, outsideViewLayer: view.layer)
		view.addSubview(scanningView!)
		
		setupScanningQRCode()
        
    }
	
	// MARK: - - - 二维码扫描
	func setupScanningQRCode() {
		// 初始化AVCaptureSession对象（会话对象）
		session = AVCaptureSession()
		// 实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
		previewLayer = AVCaptureVideoPreviewLayer(session: session)
		
		// 1、获取摄像设备
		let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		// 2、创建输入流
		let input = try? AVCaptureDeviceInput(device: device)
		// 3、创建输出流
		let output = AVCaptureMetadataOutput()
		// 4、设置代理 在主线程里刷新
		output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
		
		
		// 高质量采集率
		//session.sessionPreset = AVCaptureSessionPreset1920x1080; // 如果二维码图片过小、或者模糊请使用这句代码，注释下面那句代码
		session?.sessionPreset = AVCaptureSessionPresetHigh
		
		// 5.1 添加会话输入
		session?.addInput(input)
		// 5.2 添加会话输出
		session?.addOutput(output)
		// 6、设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
		// 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
		output.metadataObjectTypes = [AVMetadataObjectTypeUPCECode,
		                              AVMetadataObjectTypeCode39Code,
		                              AVMetadataObjectTypeCode39Mod43Code,
		                              AVMetadataObjectTypeCode93Code,
		                              AVMetadataObjectTypeCode128Code,
		                              AVMetadataObjectTypeEAN8Code,
		                              AVMetadataObjectTypeEAN13Code,
		                              AVMetadataObjectTypeAztecCode,
		                              AVMetadataObjectTypePDF417Code,
		                              AVMetadataObjectTypeQRCode]
		// 7、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
		previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
		previewLayer?.frame = view.layer.bounds
		// 8、将图层插入当前视图
		view.layer.insertSublayer(previewLayer!, at: 0)
		// 9、启动会话
		session?.startRunning()

		
	}

	
	// 调用代理方法，会频繁的扫描
	
	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
		
		// 0、扫描成功之后的提示音
		//	playSoundEffect("sound.caf")
		// 1、如果扫描完成，停止会话
		// session?.stopRunning()

	
		guard metadataObjects.count > 0  else {
			return
		}
		
		let obj: AVMetadataMachineReadableCodeObject? = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
		print("metadataObjects = \(metadataObjects)")
		// 此处可以跳转
		if (obj?.stringValue?.hasPrefix("http"))! {
			//            ScanSuccessJumpVC *jumpVC = [[ScanSuccessJumpVC alloc] init];
			//            jumpVC.jump_URL = obj.stringValue;
			//            NSLog(@"stringValue = = %@", obj.stringValue);
			//            [self.navigationController pushViewController:jumpVC animated:YES];
		}
		else {
			// 扫描结果为条形码
			scanningView?.textFiled?.text = obj?.stringValue
			self.delegate?.getVoucherNum(number: (obj?.stringValue)!)
		}

		
	}
	

	/** 播放音效文件 */
	
	func playSoundEffect(_ name: String) {
		// 获取音效
		let audioFile: String? = Bundle.main.path(forResource: name, ofType: nil)
		let fileUrl = URL(fileURLWithPath: audioFile!)
		// 1、获得系统声音ID
		var soundID: SystemSoundID = 0
		AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundID)
		// 如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
		AudioServicesAddSystemSoundCompletion(soundID, nil, nil, { (soundID, nil) in
			print("播放完成...")
		}, nil)		// 2、播放音频
		AudioServicesPlaySystemSound(soundID)
		// 播放音效
	}
	
	// MARK: - - - 移除定时器
	override func viewDidDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		scanningView?.removeTimer()
		scanningView?.removeFromSuperview()
		scanningView = nil
	}

}




