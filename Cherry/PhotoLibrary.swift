//
//  PhotoLibrary.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import Photos
import SwiftUI
import OrderedCollections

final class PhotoLibrary: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    
    @Published var assets = OrderedDictionary<String, [PHAsset]>()
    @Published var hasAuthorization: Bool = false
    
    private var authorizationStatus: PHAuthorizationStatus = .notDetermined {
        didSet {
            hasAuthorization = authorizationStatus == .authorized
                            || authorizationStatus == .limited
        }
    }
    
    var keys: [String] {
        return Array(assets.keys)
    }
    
    func binding(for key: String) -> Binding<[PHAsset]> {
        return Binding(get: {
            return self.assets[key] ?? []
        }, set: {
            self.assets[key] = $0
        })
    }
    
    private(set) var fetchResult: PHFetchResult<PHAsset>?
    
    override init() {
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    private func requestAuthorization() async -> PHAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                continuation.resume(with: .success(status))
            }
        }
    }
    
    @MainActor
    func load() async {
        Task {
            authorizationStatus = await requestAuthorization()
            
            guard authorizationStatus == .authorized else { return }
            
            let grouped = await fetchPhotos().groupedByDate()
            let allResults = await withTaskGroup(of: (String, [PHAsset]).self,
                                                 returning: OrderedDictionary<String, [PHAsset]>.self,
                                                 body: { taskGroup in
                let keys = grouped.keys
                for key in keys {
                    taskGroup.addTask { [weak self] in
                        let extracted = await self?.extractSimilarAssets(from: grouped[key] ?? [])
                        let sorted = extracted?.sorted { $0.creationDate! < $1.creationDate! } ?? []
                        return (key, sorted)
                    }
                }
                
                var childTaskResults = OrderedDictionary<String, [PHAsset]>()
                
                for await (key, assets) in taskGroup {
                    childTaskResults[key] = assets
                }
                
                childTaskResults.sort { $0.key > $1.key }
                
                return childTaskResults
            })
            
            await MainActor.run {
                withAnimation {
                    self.assets = allResults
                }
            }
        }
    }
    
    private func fetchPhotos() async -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: FetchingKey.creationDate, ascending: true)]
        if fetchResult == nil {
            fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        }
        var assets = [PHAsset]()
        fetchResult?.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { [weak self] in
            if let changes = changeInstance.changeDetails(for: fetchResult!) {
                self?.fetchResult = changes.fetchResultAfterChanges
                await load()
            }
        }
    }
}

private extension PhotoLibrary {
    func extractSimilarAssets(from assets: [PHAsset]) async -> [PHAsset] {
        var images = [(asset: PHAsset, image: UIImage)]()
        var result = Set<PHAsset>()
        
        for asset in assets {
            let loader = ImageLoader(phasset: asset, size: CGSize(width: 1, height: 1))
            if let image = await loader.loadImage() {
                images.append((asset, image))
            }
        }
        
        for sourceIndex in 0..<images.count {
            for targetIndex in sourceIndex+1..<images.count {
                let source = images[sourceIndex]
                let target = images[targetIndex]
                let similarity = HistogramClassifier().computeSimilarity(source.image, targetImage: target.image)
                if similarity > 0.8 {
                    result.insert(source.asset)
                    result.insert(target.asset)
                }
            }
        }
        
        return Array(result)
    }
}

private extension PhotoLibrary {
    struct FetchingKey {
        static let creationDate = "creationDate"
    }
}

extension Array where Element == PHAsset {
    func groupedByDate() -> Dictionary<String, [PHAsset]> {
        return Dictionary(grouping: self, by: { $0.creationDate!.formatted() })
    }
}

private extension Date {
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: self)
    }
}
