//
//  FTDiffableCollectionDataSourceHelper.swift
//  FATCustomNodes
//
//  Created by Xiangyu Wang on 7/29/25.
//

import Foundation
import UIKit
import SwiftUI

open class CustomDiffableCollectionDataSourceHelper<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: NSObject, UICollectionViewDelegate {
    public typealias DiffableDataSource = UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>
    public typealias DiffableSnapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>

    public weak var collectionView: UICollectionView?
    public weak var dataSource: DiffableDataSource?
    
    public var customHeaderGenerator: ((UICollectionView, String, IndexPath) -> AnyView?)? = nil
    public var customFooterGenerator: ((UICollectionView, String, IndexPath) -> AnyView?)? = nil
    public var customCellGenerator: ((UICollectionView, IndexPath, ItemIdentifier) -> AnyView) = {_, _, _ in AnyView(ZStack{})}
    
    @ViewBuilder
    open func headerGenerator(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> (some View)? {
        self.customHeaderGenerator?(collectionView, kind, indexPath)
    }
    
    @ViewBuilder
    open func footerGenerator(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> (some View)? {
        self.customFooterGenerator?(collectionView, kind, indexPath)
    }
    
    @ViewBuilder
    open func cellGenerator(collectionView: UICollectionView, indexPath: IndexPath, item: ItemIdentifier) -> some View {
        self.customCellGenerator(collectionView, indexPath, item)
    }
    
    public func makeDataSource(collectionView: UICollectionView) -> DiffableDataSource {
        let dataSource = DiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let updateCellNode = self.cellGenerator(collectionView: collectionView, indexPath: indexPath, item: item)
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomDiffableCollectionCell.reuseIdentifier, for: indexPath) as? CustomDiffableCollectionCell {
                cell.updateContainer(UIHostingController(rootView: updateCellNode))
                return cell
            } else {
                let newCell = CustomDiffableCollectionCell()
                newCell.updateContainer(UIHostingController(rootView: updateCellNode))
                return newCell
            }
        }
        self.dataSource = dataSource
        self.collectionView = collectionView
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> CustomDiffableCollectionReusableView? in
            guard collectionView.dataSource is DiffableDataSource else {
                return nil
            }
            if kind == UICollectionView.elementKindSectionHeader, let getHeader = self.headerGenerator(collectionView: collectionView, kind: kind, indexPath: indexPath) {
                if let title = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomDiffableCollectionReusableView.reuseHeaderIdentifier, for: indexPath) as? CustomDiffableCollectionReusableView {
                    title.updateContainer(UIHostingController(rootView: getHeader))
                    return title
                } else {
                    let newView = CustomDiffableCollectionReusableView()
                    newView.updateContainer(UIHostingController(rootView: getHeader))
                    return newView
                }
            }
            if kind == UICollectionView.elementKindSectionFooter, let getFooter = self.footerGenerator(collectionView: collectionView, kind: kind, indexPath: indexPath) {
                if let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CustomDiffableCollectionReusableView.reuseFooterIdentifier, for: indexPath) as? CustomDiffableCollectionReusableView {
                    footer.updateContainer(UIHostingController(rootView: getFooter))
                    return footer
                } else {
                    let newView = CustomDiffableCollectionReusableView()
                    newView.updateContainer(UIHostingController(rootView: getFooter))
                    return newView
                }
            }
            return nil
        }
        
        return dataSource
    }
    
    open func batchFetchOnItem() -> Int {
        return 4
    }
    
    open func shouldBatchFetch(collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func batchFetchAction(collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath) {
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row >= collectionView.numberOfItems(inSection: indexPath.section) - self.batchFetchOnItem(), shouldBatchFetch(collectionView: collectionView, cell: cell, indexPath: indexPath) {
            batchFetchAction(collectionView: collectionView, cell: cell, indexPath: indexPath)
        }
    }
}
