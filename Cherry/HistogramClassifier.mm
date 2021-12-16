//
//  HistogramClassifier.m
//  Cherry
//
//  Created by junyeong-cho on 2021/12/16.
//

#import "HistogramClassifier.h"
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/imgcodecs/ios.h>

@implementation HistogramClassifier

- (double)computeSimilarity:(UIImage *) sourceImage targetImage:(UIImage *) targetImage {
    cv::Mat src_baseImage, hsv_baseImage;
    cv::Mat src_compareImage, hsv_compareImage;

    UIImageToMat(sourceImage, src_baseImage);
    UIImageToMat(targetImage, src_compareImage);

    cvtColor(src_baseImage, hsv_baseImage, cv::COLOR_BGR2HSV);
    cvtColor(src_compareImage, hsv_compareImage, cv::COLOR_BGR2HSV);

    int h_bins = 50;
    int s_bins = 60;
    int histSize[] = { h_bins, s_bins };
    float h_ranges[] = { 0, 180 };
    float s_ranges[] = { 0, 256 };
    const float* ranges[] = { h_ranges, s_ranges };
    int channels[] = { 0, 1 };

    cv::MatND hist_baseImage;
    cv::MatND hist_compareImage;
    cv::calcHist(&hsv_baseImage, 1, channels, cv::Mat(), hist_baseImage, 2, histSize, ranges, true, false);
    normalize(hist_baseImage, hist_baseImage, 0, 1, cv::NORM_MINMAX, -1, cv::Mat());
    cv::calcHist(&hsv_compareImage, 1, channels, cv::Mat(), hist_compareImage, 2, histSize, ranges, true, false);
    normalize(hist_compareImage, hist_compareImage, 0, 1, cv::NORM_MINMAX, -1, cv::Mat());
    
    return compareHist(hist_baseImage, hist_compareImage, 0);
}

@end
