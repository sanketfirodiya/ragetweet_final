/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import TwitterKit

class ViewController: UIViewController, UIScrollViewDelegate {
  @IBOutlet weak var skyView: SkyView!
  @IBOutlet weak var containerScrollView: ContainerScrollView!

  override func viewDidLoad() {
    super.viewDidLoad()
    let viewWidth = view.frame.size.width
    let scrollView = UIScrollView(frame: CGRect(x: viewWidth/4, y: 0, width: viewWidth/2, height: 300))
    scrollView.contentSize = CGSize(width: viewWidth * 2.5, height: 200)
    scrollView.isPagingEnabled = true
    scrollView.clipsToBounds = false
    scrollView.delegate = self;

    let scrollViewWidth = scrollView.frame.size.width

    for rageLevel in RageLevel.allCases {
      let imageView = UIImageView.init(image: rageLevel.image)
      let currentXOffset: CGFloat = (scrollViewWidth/2 - imageView.frame.size.width/2) + CGFloat(rageLevel.rawValue) * scrollViewWidth
      let button = UIButton(frame: CGRect(x: currentXOffset, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
      button.tag = rageLevel.rawValue
      button.setImage(rageLevel.image, for: .normal)
      button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
      scrollView.addSubview(button)
    }

    containerScrollView.setScrollView(scrollView)
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let pageNum: Int = (Int(scrollView.contentOffset.x / scrollView.frame.size.width));
    if let rageLevel = RageLevel(rawValue: pageNum) {
      skyView.setRageLevel(rageLevel)
    }
  }

  @objc func buttonTapped(sender: UIButton) {
    if (TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
      showTweetCompose(sender.tag)
    } else {
      TWTRTwitter.sharedInstance().logIn { [weak self] session, error in
        guard let self = self else { return }

        if session != nil {
          self.showTweetCompose(sender.tag)
        } else {
          let alert = UIAlertController(title: "Twitter Unavailable", message: "Please turn to your nearest mirror and rage away", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
          self.present(alert, animated: false, completion: nil)
        }
      }
    }
  }

  private func showTweetCompose(_ index: Int) {
    let composer = TWTRComposer()

    if let rageLevel = RageLevel(rawValue: index) {
      composer.setText(rageLevel.tweet)
      composer.setImage(rageLevel.image)
    }

    composer.show(from: self, completion: nil)
  }
}
