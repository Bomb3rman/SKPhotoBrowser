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
    
    private var currentTimeLabel: UILabel!
    private var remainingTimeLabel: UILabel!
    private var slider: SKVideoSlider!
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        currentTimeLabel = UILabel()
        currentTimeLabel.text = "00000"
        currentTimeLabel.font = UIFont.systemFontOfSize(12)
        currentTimeLabel.textColor = .whiteColor()
        currentTimeLabel.sizeToFit()
        addSubview(currentTimeLabel)
        
        remainingTimeLabel = UILabel()
        remainingTimeLabel.text = "00000"
        remainingTimeLabel.font = UIFont.systemFontOfSize(12)
        remainingTimeLabel.textColor = .whiteColor()
        remainingTimeLabel.sizeToFit()
        addSubview(remainingTimeLabel)
        
        slider = SKVideoSlider()
        let sliderTrackImage = UIImage(named: "SKPhotoBrowser.bundle/images/btn_video_slider_handle", inBundle: NSBundle(forClass: SKPhotoBrowser.self), compatibleWithTraitCollection: nil)
        
        slider.addTarget(self, action: #selector(sliderValueChanged), forControlEvents: .ValueChanged)
        slider.addTarget(self, action: #selector(sliderTouchBegin), forControlEvents: .TouchDown)
        slider.addTarget(self, action: #selector(sliderTouchEnd), forControlEvents: [.TouchUpInside, .TouchUpOutside])
        
        slider.setThumbImage(sliderTrackImage, forState: .Normal)
        slider.minimumTrackTintColor = .whiteColor()
        slider.maximumTrackTintColor = .lightGrayColor()
        
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
        NSNotificationCenter.defaultCenter().postNotificationName(SKVideoScrubber.ValueChanged, object: nil, userInfo: userInfo)
    }
    
    func sliderTouchBegin() {
        NSNotificationCenter.defaultCenter().postNotificationName(SKVideoScrubber.Start, object: nil)
    }
    
    func sliderTouchEnd() {
        NSNotificationCenter.defaultCenter().postNotificationName(SKVideoScrubber.End, object: nil)
    }
}

class SKVideoSlider: UISlider {
    
    var thumbTouchSize : CGSize = CGSizeMake(50, 50)
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let bounds = CGRectInset(self.bounds, -thumbTouchSize.width, -thumbTouchSize.height);
        return CGRectContainsPoint(bounds, point);
    }
}
