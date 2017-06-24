//
//  YHYScanningQRCodeView.swift
//  LookingForCharging
//
//  Created by 太阳在线YHY on 2017/3/24.
//  Copyright © 2017年 太阳在线. All rights reserved.
//

import UIKit
import AVFoundation

class YHYScanningQRCodeView: UIView {

	var basedLayer: CALayer?
	var device: AVCaptureDevice?
	/** 扫描动画线(冲击波) */
	var animationLine: UIImageView?
	var textFiled: UITextField?

	var timer: Timer?
	var tap: UITapGestureRecognizer?
	
	/** 扫描内容的Y值 */
	var scanContentX:CGFloat!
	var scanContentY:CGFloat!
	
	
	/** 扫描动画线(冲击波) 的高度 */
	
	let animationLineH: CGFloat = 12
	/** 扫描内容外部View的alpha值 */
	let scanBorderOutsideViewAlpha: CGFloat = 0.4
	/** 定时器和动画的时间 */
	let timerAnimationDuration: CGFloat = 0.05
	var flag: Bool = true
	
	init(frame: CGRect, outsideViewLayer: CALayer) {
		super.init(frame: frame)
		//	self.backgroundColor = UIColor.red
		isUserInteractionEnabled = true
		
		scanContentY = self.frame.size.height * 0.15
		scanContentX = self.frame.size.width * 0.15
		basedLayer = outsideViewLayer
		// 创建扫描边框
		setupScanningQRCodeEdging()
		addViewTapGesture()
		
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func addViewTapGesture() {
		tap = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
		addGestureRecognizer(tap!)
	}
	
	func tapView() {
		endEditing(true)
	}

	
	func setupScanningQRCodeEdging() {
		// 扫描区域的创建
		let scanContentLayer = CALayer()
		let scanContentLayerX: CGFloat = scanContentX
		let scanContentLayerY: CGFloat = scanContentY
		let scanContentLayerW: CGFloat = frame.size.width - 2 * scanContentX
		let scanContentLayerH: CGFloat = scanContentLayerW
		scanContentLayer.frame = CGRect(x: scanContentLayerX, y: scanContentLayerY, width: scanContentLayerW, height: scanContentLayerH)
		scanContentLayer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
		scanContentLayer.borderWidth = 0.7
		scanContentLayer.backgroundColor = UIColor.clear.cgColor
		basedLayer?.addSublayer(scanContentLayer)
		
		// 顶部layer的创建
		let topLayer = CALayer()
		let topLayerX: CGFloat = 0
		let topLayerY: CGFloat = 0
		let topLayerW: CGFloat = frame.size.width
		let topLayerH: CGFloat = scanContentLayerY
		topLayer.frame = CGRect(x: topLayerX, y: topLayerY, width: topLayerW, height: topLayerH)
		topLayer.backgroundColor = UIColor.black.withAlphaComponent(scanBorderOutsideViewAlpha).cgColor
		layer.addSublayer(topLayer)
		// 左侧layer的创建
		let leftLayer = CALayer()
		let leftLayerX: CGFloat = 0
		let leftLayerY: CGFloat = scanContentLayerY
		let leftLayerW: CGFloat = scanContentX
		let leftLayerH: CGFloat = scanContentLayerH
		leftLayer.frame = CGRect(x: leftLayerX, y: leftLayerY, width: leftLayerW, height: leftLayerH)
		leftLayer.backgroundColor = UIColor.black.withAlphaComponent(scanBorderOutsideViewAlpha).cgColor
		layer.addSublayer(leftLayer)
	
		// 右侧layer的创建
		let rightLayer = CALayer()
		let rightLayerX: CGFloat = scanContentLayer.frame.maxX
		let rightLayerY: CGFloat = scanContentLayerY
		let rightLayerW: CGFloat = scanContentX
		let rightLayerH: CGFloat = scanContentLayerH
		rightLayer.frame = CGRect(x: rightLayerX, y: rightLayerY, width: rightLayerW, height: rightLayerH)
		rightLayer.backgroundColor = UIColor.black.withAlphaComponent(scanBorderOutsideViewAlpha).cgColor
		layer.addSublayer(rightLayer)
		// 下面layer的创建
		let bottomLayer = CALayer()
		let bottomLayerX: CGFloat = 0
		let bottomLayerY: CGFloat = scanContentLayer.frame.maxY
		let bottomLayerW: CGFloat = frame.size.width
		let bottomLayerH: CGFloat = frame.size.height - bottomLayerY
		bottomLayer.frame = CGRect(x: bottomLayerX, y: bottomLayerY, width: bottomLayerW, height: bottomLayerH)
		bottomLayer.backgroundColor = UIColor.black.withAlphaComponent(scanBorderOutsideViewAlpha).cgColor
		layer.addSublayer(bottomLayer)
		
		// 提示Label
		let promptLabel = UILabel()
		promptLabel.backgroundColor = UIColor.clear
		let promptLabelX: CGFloat = 0
		let promptLabelY: CGFloat = scanContentLayer.frame.maxY + 15
		let promptLabelW: CGFloat = frame.size.width
		let promptLabelH: CGFloat = 20
		promptLabel.frame = CGRect(x: promptLabelX, y: promptLabelY, width: promptLabelW, height: promptLabelH)
		promptLabel.textAlignment = .center
		promptLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(13.0))
		promptLabel.textColor = UIColor.white.withAlphaComponent(0.6)
		promptLabel.text = "将二维码/条码放入框内, 即可自动扫描"
		addSubview(promptLabel)
		// 添加闪光灯按钮
		let lightButton = UIButton()
		let lightButtonX: CGFloat = 0
		let lightButtonY: CGFloat = promptLabel.frame.maxY + scanContentX * 0.5
		let lightButtonW: CGFloat = frame.size.width
		let lightButtonH: CGFloat = 25
		lightButton.frame = CGRect(x: lightButtonX, y: lightButtonY, width: lightButtonW, height: lightButtonH)
		lightButton.setTitle("打开照明灯", for: .normal)
		lightButton.setTitle("关闭照明灯", for: .selected)
		lightButton.setTitleColor(promptLabel.textColor, for: (.normal))
		lightButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(17))
		lightButton.addTarget(self, action: #selector(self.lightButtonAction), for: .touchUpInside)
		addSubview(lightButton)
		
		
		// 添加一个输入框 可以显示扫描出来的结果  也可以输入条形码的号码
		textFiled = UITextField()
        textFiled!.translatesAutoresizingMaskIntoConstraints = false
	
		textFiled?.backgroundColor = UIColor.white.withAlphaComponent(scanBorderOutsideViewAlpha)
		textFiled?.placeholder = "手动输入"
		textFiled?.font = UIFont.systemFont(ofSize: CGFloat(16))
		textFiled?.textAlignment = .center
		textFiled?.clearButtonMode = .always
		addSubview(textFiled!)
		
		let centerX = NSLayoutConstraint(item: textFiled!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
		
		let bottom = NSLayoutConstraint(item: textFiled!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -12)
		
		let width = NSLayoutConstraint(item: textFiled!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0)
		
		let height = NSLayoutConstraint(item: textFiled!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 44)
		
		NSLayoutConstraint.activate([centerX,bottom,width,height])
		
		
		// 扫描动画添加
		
	    let lineImageView = UIImageView()
		animationLine = lineImageView
		lineImageView.image = UIImage(named: "QRCodeLine")
		lineImageView.frame = CGRect(x: CGFloat(scanContentX * 0.5), y: CGFloat(scanContentLayerY), width: CGFloat(frame.size.width - scanContentX), height: CGFloat(animationLineH))
		self.addSubview(lineImageView)
		//		// 添加定时器
		timer = Timer.scheduledTimer(timeInterval: TimeInterval(timerAnimationDuration), target: self, selector: #selector(self.animationLineAction), userInfo: nil, repeats: true)
		
		
		// 左上侧的image
		let margin: CGFloat = 7
		let leftimage = UIImage(named: "QRCodeTopLeft")
		let leftimageView = UIImageView()
		let leftimageViewX = scanContentLayer.frame.minX - leftimage!.size.width * 0.5 + margin
		let leftimageViewY = scanContentLayer.frame.minY - leftimage!.size.width * 0.5 + margin
		let leftimageViewW = leftimage!.size.width
		let leftimageViewH = leftimage!.size.height
		leftimageView.frame = CGRect(x: CGFloat(leftimageViewX), y: CGFloat(leftimageViewY), width: CGFloat(leftimageViewW), height: CGFloat(leftimageViewH))
		leftimageView.image = leftimage
		basedLayer?.addSublayer(leftimageView.layer)
		// 右上侧的image
		let rightimage = UIImage(named: "QRCodeTopRight")
		let rightimageView = UIImageView()
		let rightimageViewX = scanContentLayer.frame.maxX - rightimage!.size.width * 0.5 - margin
		let rightimageViewY = leftimageView.frame.origin.y
		let rightimageViewW = leftimage!.size.width
		let rightimageViewH = leftimage!.size.height
		rightimageView.frame = CGRect(x: CGFloat(rightimageViewX), y: rightimageViewY, width: rightimageViewW, height: rightimageViewH)
		rightimageView.image = rightimage
		basedLayer?.addSublayer(rightimageView.layer)
		// 左下侧的image
		let leftimageDown = UIImage(named: "QRCodebottomLeft")
		let leftimageViewDown = UIImageView()
		let leftimageViewDownX = leftimageView.frame.origin.x
		let leftimageViewDownY = scanContentLayer.frame.maxY - leftimageDown!.size.width * 0.5 - margin
		let leftimageViewDownW = leftimage!.size.width
		let leftimageViewDownH = leftimage!.size.height
		
		leftimageViewDown.frame = CGRect(x: CGFloat(leftimageViewDownX), y: CGFloat(leftimageViewDownY), width: CGFloat(leftimageViewDownW), height: CGFloat(leftimageViewDownH))
		leftimageViewDown.image = leftimageDown
		basedLayer?.addSublayer(leftimageViewDown.layer)
		// 右下侧的image
		let rightimageDown = UIImage(named: "QRCodebottomRight")
		let rightimageViewDown = UIImageView()
		let rightimageViewDownX: CGFloat = rightimageView.frame.origin.x
		let rightimageViewDownY: CGFloat = leftimageViewDown.frame.origin.y
		let rightimageViewDownW: CGFloat = leftimage!.size.width
		let rightimageViewDownH: CGFloat = leftimage!.size.height
		rightimageViewDown.frame = CGRect(x: CGFloat(rightimageViewDownX), y: CGFloat(rightimageViewDownY), width: CGFloat(rightimageViewDownW), height: CGFloat(rightimageViewDownH))
		rightimageViewDown.image = rightimageDown
		basedLayer?.addSublayer(rightimageViewDown.layer)

		
	}
	
	// 打开手电筒
	func lightButtonAction(_ button: UIButton) {
		if button.isSelected == false {
			// 点击打开照明灯
			turn(onLight: true)
			button.isSelected = true
		}
		else {
			// 点击关闭照明灯
			turn(onLight: false)
			button.isSelected = false
		}
	}
	
	func turn(onLight on: Bool) {
		device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		if (device?.hasTorch)! {
			try! device?.lockForConfiguration()
			if on {
				device?.torchMode = .on
			}
			else {
				device?.torchMode = .off
			}
			device?.unlockForConfiguration()
		}
	}

	
	func animationLineAction() {
		var frame: CGRect = animationLine!.frame
		if flag {
			frame.origin.y = scanContentY
			flag = false
			UIView.animate(withDuration: TimeInterval(timerAnimationDuration), animations: {() -> Void in
				frame.origin.y += 5
				self.animationLine?.frame = frame
			}, completion: { _ in })
		}
		else {
			if animationLine!.frame.origin.y >= scanContentY {
                let scanContentMaxY: CGFloat = scanContentY + frame.size.width - 2 * scanContentX
				if (animationLine?.frame.origin.y)! >= scanContentMaxY - 10 {
					frame.origin.y = scanContentY
					animationLine?.frame = frame
					flag = true
				}
				else {
					UIView.animate(withDuration: TimeInterval(timerAnimationDuration), animations: {() -> Void in
						frame.origin.y += 3
						self.animationLine?.frame = frame
					}, completion: { _ in })
				}
			}
			else {
               flag = !flag
			}

		}
	}

	
	
	// MARK: - - - 移除定时器
	func removeTimer() {
		timer?.invalidate()
		animationLine?.removeFromSuperview()
		animationLine = nil
	}

	

}

