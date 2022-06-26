//
//  CherryService.swift
//  Cherry
//
//  Created by junyng on 2022/06/18.
//

import Foundation

class CherryService {
    private let classifier: HistogramClassifier
    private let loader: _ImageLoader
    
    init(
        classifier: HistogramClassifier,
        loader: _ImageLoader
    ) {
        self.classifier = classifier
        self.loader = loader
    }
    
    func fetchSimilarAssets(from assets: [PhotoAsset]) async throws -> [PhotoAsset] {
        var assetImageMap = [PhotoAsset : UIImage]()
        var result = Set<PhotoAsset>()
        
        for asset in assets {
            guard let image = await loader.load(from: asset.id, size: .minimum) else {
                continue
            }
            
            assetImageMap[asset] = image
        }
        
        let assets = assetImageMap.keys
        
        for source in assets {
            let filtered = assets.filter { $0.id != source.id }
            
            for target in filtered {
                guard let sourceImage = assetImageMap[source],
                      let targetImage = assetImageMap[target] else {
                          continue
                      }
                
                let similarity = classifier.computeSimilarity(
                    sourceImage,
                    targetImage: targetImage)
                
                if similarity > 0.8 {
                    result.insert(source)
                    result.insert(target)
                }
            }
        }
        
        return Array(result)
    }
}

private extension CGSize {
    static var minimum: CGSize = .init(width: 1, height: 1)
}
