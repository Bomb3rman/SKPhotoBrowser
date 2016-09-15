//
//  SKVideoScrubber.swift
//  SKPhotoBrowser
//
//  Created by Omair Baskanderi on 2016-09-12.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

class SKVideoScrubber: UIView {
    
    static let Start        = "SKVideoScrubberStart"
    static let End          = "SKVideoScrubberEnd"
    static let ValueChanged = "SKVideoScrubberValueChanged"
    static let ValueKey     = "SliderValue"
    
    var duration: Float = 0.0 {
        didSet {
            currentTimeLabel.text = "00:00"
            remainingTimeLabel.text =  String(format: "%02d:%02d", ((lroundf(duration) / 60) % 60), lroundf(duration) % 60)
            slider.value = 0
        }
    }
    
    var currentTime: Float = 0.0 {
        didSet {
            currentTimeLabel.text = String(format: "%02d:%02d", ((lroundf(currentTime) / 60) % 60), lroundf(currentTime) % 60)
            
            let remainingTime = duration - currentTime
            remainingTimeLabel.text =  String(format: "%02d:%02d", ((lroundf(remainingTime) / 60) % 60), lroundf(remainingTime) % 60)
        }
    }
    
    var progress: Float = 0 {
        didSet {
            if let slider = self.slider {
                slider.setValue(progress, animated: true)
            }
        }
    }
    
    fileprivate var currentTimeLabel: UILabel!
    fileprivate var remainingTimeLabel: UILabel!
    fileprivate var slider: SKVideoSlider!
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        currentTimeLabel = UILabel()
        currentTimeLabel.text = "00000"
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        currentTimeLabel.textColor = .white
        currentTimeLabel.sizeToFit()
        addSubview(currentTimeLabel)
        
        remainingTimeLabel = UILabel()
        remainingTimeLabel.text = "00000"
        remainingTimeLabel.font = UIFont.systemFont(ofSize: 12)
        remainingTimeLabel.textColor = .white
        remainingTimeLabel.sizeToFit()
        addSubview(remainingTimeLabel)
        
        slider = SKVideoSlider()
        let sliderTrackImage = UIImage(named: "SKPhotoBrowser.bundle/images/btn_video_slider_handle", in: Bundle(for: SKPhotoBrowser.self), compatibleWith: nil)
        
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchBegin), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchEnd), for: [.touchUpInside, .touchUpOutside])
        
        slider.setThumbImage(sliderTrackImage, for: UIControlState())
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .lightGray
        
        addSubview(slider)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        currentTimeLabel.frame.origin = CGPoint(x: 0, y: 0)
        
        let sliderWidth = frame.width - currentTimeLabel.frame.size.width - remainingTimeLabel.frame.size.width - 30
        let sliderXPos = currentTimeLabel.frame.origin.x + currentTimeLabel.frame.width + 5
        slider.frame = CGRect(x: sliderXPos, y: 4, width: sliderWidth, height: 5)
        
        remainingTimeLabel.frame.origin.x = slider.frame.origin.x + slider.frame.width + 5
        remainingTimeLabel.frame.origin.y = 0
    }
}

extension SKVideoScrubber {
    func sliderValueChanged() {
        let userInfo = [ SKVideoScrubber.ValueKey : slider.value ]
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKVideoScrubber.ValueChanged), object: nil, userInfo: userInfo)
    }
    
    func sliderTouchBegin() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKVideoScrubber.Start), object: nil)
    }
    
    func sliderTouchEnd() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKVideoScrubber.End), object: nil)
    }
}

class SKVideoSlider: UISlider {
    
    var thumbTouchSize : CGSize = CGSize(width: 50, height: 50)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let bounds = self.bounds.insetBy(dx: -thumbTouchSize.width, dy: -thumbTouchSize.height);
        return bounds.contains(point);
    }
}
