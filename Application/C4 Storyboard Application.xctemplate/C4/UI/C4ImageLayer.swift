// Copyright © 2014 C4
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright
// notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import QuartzCore

///Subclass of CALayer that handles animating its contents.
public class C4ImageLayer: CALayer {
    /// Configures basic options for a CABasicAnimation.
    ///
    /// The options set in this method are favorable for the inner workings of C4's animation behaviours.
    /// - parameter key: The identifier of the action.
    /// - returns: The object that provides the action for key.
    public override func actionForKey(key: String) -> CAAction? {
        if C4ShapeLayer.disableActions == true {
            return nil
        }

        if key != "contents" {
            return super.actionForKey(key)
        }

        let animation: CABasicAnimation
        if let viewAnimation = C4ViewAnimation.stack.last as? C4ViewAnimation where viewAnimation.spring != nil {
            animation = CASpringAnimation(keyPath: key)
        } else {
            animation = CABasicAnimation(keyPath: key)
        }

        animation.configureOptions()
        animation.fromValue = self.contents

        return animation
    }
}
