//
//  HistogramClassifier.h
//  Cherry
//
//  Created by junyeong-cho on 2021/12/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HistogramClassifier: NSObject

- (double)computeSimilarity:(UIImage *) sourceImage targetImage: (UIImage *) targetImage;

@end
NS_ASSUME_NONNULL_END
