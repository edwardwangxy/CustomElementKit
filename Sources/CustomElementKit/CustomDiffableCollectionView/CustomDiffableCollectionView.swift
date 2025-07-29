//
//  File.swift
//  CustomElementKit
//
//  Created by Xiangyu Wang on 7/29/25.
//

import Foundation
import SwiftUI

open class CustomDiffableCollectionUIView<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: UIView {
    public var collectionView: UICollectionView!
    public var data: CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>!
    public var dataSource: CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>.DiffableDataSource!
    public var config: ((UICollectionView) -> Void) = { _ in }
    public var customLayout: UICollectionViewLayout? = nil
    
    public convenience init(data: CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>) {
        self.init()
        self.config = config
        self.data = data
        self.setup(layout: self.layout(), config: self.config)
    }
    
    public func viewReload() {
        self.collectionView.removeFromSuperview()
        self.setup(layout: self.customLayout ?? self.layout(), config: self.config)
    }
    
    open func layout() -> UICollectionViewLayout {
        return self.customLayout ?? UICollectionViewFlowLayout()
    }
    
    public func setup(layout: UICollectionViewLayout, config: (UICollectionView) -> Void) {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.register(CustomDiffableCollectionCell.self, forCellWithReuseIdentifier: CustomDiffableCollectionCell.reuseIdentifier)
        self.collectionView.register(CustomDiffableCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomDiffableCollectionReusableView.reuseHeaderIdentifier)
        self.collectionView.register(CustomDiffableCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CustomDiffableCollectionReusableView.reuseFooterIdentifier)
        
        config(self.collectionView)
        
        self.dataSource = self.data.makeDataSource(collectionView: self.collectionView)
        self.collectionView.dataSource = self.dataSource
        self.collectionView.delegate = self.data
        self.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
}

public protocol CustomDiffableSectionData {
    associatedtype SectionIdentifier: Hashable
    associatedtype ItemIdentifier: Hashable
    
    var section: SectionIdentifier { get set }
    var items: [ItemIdentifier] { get set }
}

public struct CustomDiffableCollectionView<SectionIdentifier: Hashable, ItemIdentifier: Hashable, SectionData: CustomDiffableSectionData>: UIViewRepresentable where SectionData.SectionIdentifier == SectionIdentifier, SectionData.ItemIdentifier == ItemIdentifier {
    
    public typealias UIViewType = CustomDiffableCollectionUIView<SectionIdentifier, ItemIdentifier>
    
    let dataHelper: CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>
    var customLayout: UICollectionViewLayout? = nil
    var needReload: Bool = false
    var collectionConfig: (UICollectionView) -> Void = {_ in }
    
    @Binding var data: [SectionData]
    
    public init(data: Binding<[SectionData]>, cell: @escaping (UICollectionView, IndexPath, ItemIdentifier) -> AnyView, header: ((UICollectionView, String, IndexPath) -> AnyView?)? = nil, footer: ((UICollectionView, String, IndexPath) -> AnyView?)? = nil) {
        self.dataHelper = CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>()
        self.dataHelper.customCellGenerator = cell
        self.dataHelper.customHeaderGenerator = header
        self.dataHelper.customFooterGenerator = footer
        self._data = data
    }
    
    public func makeUIView(context: Context) -> CustomDiffableCollectionUIView<SectionIdentifier, ItemIdentifier> {
        let uiView = CustomDiffableCollectionUIView(data: self.dataHelper)
        uiView.config = self.collectionConfig
        uiView.customLayout = self.customLayout
        uiView.viewReload()
        return uiView
    }
    
    public func updateUIView(_ uiView: CustomDiffableCollectionUIView<SectionIdentifier, ItemIdentifier>, context: Context) {
        if self.needReload {
            uiView.config = self.collectionConfig
            uiView.customLayout = self.customLayout
            uiView.viewReload()
        }
        self.applyData(dataHelper: uiView.data)
    }
    
    func applyData(dataHelper: CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>) {
        let allData = self.data
        DispatchQueue.global().async {
            var snapshot = CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>.DiffableSnapshot()
            let allSectsions = allData.map({ $0.section })
            snapshot.appendSections(allSectsions)
            for eachSection in allData {
                snapshot.appendItems(eachSection.items, toSection: eachSection.section)
            }
            dataHelper.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    public func config(_ config: @escaping (UICollectionView) -> Void) -> Self {
        var copy = self
        copy.collectionConfig = config
        copy.needReload = true
        return copy
    }
    
    public func customLayout(_ customLayout: UICollectionViewLayout?) -> Self {
        var copy = self
        copy.customLayout = customLayout
        copy.needReload = true
        return copy
    }
}


