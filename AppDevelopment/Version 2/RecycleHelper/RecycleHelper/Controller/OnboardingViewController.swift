//
//  OnboardingViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 17/05/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    
    // Link to UI
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageCtrl: UIPageControl!
    @IBOutlet weak var startedBtn: UIButton!
    
    var scrollWidth: CGFloat! = 0.0
    var scrollHeight: CGFloat! = 0.0
    
    // Onboarding views
    var titles = ["Welcome to RecycleHelper", "Text Recognition", "Object Detection", "Recycling made easy"]
    var descriptions = ["Recycling information, specific to your location, in one place.", "Allows you to scan recycling labels.", "To even identify an object itself!", "Once the item is identified, just follow the step-by-step instructions."]
    var images = ["onboarding1","onboarding2","onboarding3","onboarding4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        // Make navigation bar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // View setup
        self.scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        // Create the slides and show them
        var frame = CGRect(x:0, y: 0, width: 0, height: 0)
        for i in 0..<titles.count {
            // Outside frame
            frame.origin.x = scrollWidth * CGFloat(i)
            frame.size = CGSize(width: scrollWidth, height: scrollHeight)
            
            let slide = UIView(frame: frame)
            
            // Image
            let imageView = UIImageView.init(image: UIImage.init(named: images[i]))
            imageView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
            imageView.contentMode = .scaleAspectFit
            imageView.center = CGPoint(x: scrollWidth/2, y: scrollHeight/2 - 50)
            
            // Title
            let title = UILabel.init(frame: CGRect(x: 32, y: imageView.frame.maxY+30, width: scrollWidth-64, height:30))
            title.textAlignment = .center
            title.font = UIFont.boldSystemFont(ofSize: 20.0)
            title.text = titles[i]
            
            // Description Text
            let text = UILabel.init(frame: CGRect(x: 32, y: title.frame.maxY+5, width: scrollWidth-64, height: 50))
            text.textAlignment = .center
            text.numberOfLines = 3
            text.font = UIFont.systemFont(ofSize: 15.0)
            text.text = descriptions[i]
            
            // Show view
            slide.addSubview(imageView)
            slide.addSubview(title)
            slide.addSubview(text)
            scrollView.addSubview(slide)
        }
        //set width of scrollview to accomodate all the slides
        scrollView.contentSize = CGSize(width: scrollWidth * CGFloat(titles.count), height: scrollHeight)

        //disable vertical scroll/bounce
        self.scrollView.contentSize.height = 1.0

        //initial state
        pageCtrl.numberOfPages = titles.count
        pageCtrl.currentPage = 0
    }
    
    override func viewDidLayoutSubviews() {
        scrollWidth = scrollView.frame.size.width
        scrollHeight = scrollView.frame.size.height
    }
    
    // Page indicator
    @IBAction func pageChanged(_ sender: Any) {
        scrollView!.scrollRectToVisible(CGRect(x: scrollWidth * CGFloat ((pageCtrl?.currentPage)!), y: 0, width: scrollWidth, height: scrollHeight), animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setIndicatorForCurrentPage()
    }

    func setIndicatorForCurrentPage()  {
        let page = (scrollView?.contentOffset.x)!/scrollWidth
        pageCtrl?.currentPage = Int(page)
    }
}
