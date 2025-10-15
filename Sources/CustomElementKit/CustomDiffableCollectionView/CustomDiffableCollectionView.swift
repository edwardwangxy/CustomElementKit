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
    public var config: ((UICollectionView) -> Void) = {_ in}
    public var layoutSubViewsAction: () -> Void = {}
    public var customLayout: UICollectionViewLayout? = nil {
        didSet {
            self.collectionView.setCollectionViewLayout(self.layout(), animated: true)
        }
    }
    
    public convenience init(data: CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>, config: @escaping (UICollectionView) -> Void = { _ in }) {
        self.init()
        self.config = config
        self.data = data
        self.setup(layout: self.layout(), config: self.config)
    }
    
    public func configController<SectionData: CustomDiffableSectionData>(controller: CustomDiffableCollectionDataController<SectionData>) where SectionData.SectionIdentifier == SectionIdentifier, SectionData.ItemIdentifier == ItemIdentifier {
        controller.applyDataConfig = { [weak self] datas in
            DispatchQueue.global().async {
                guard let self = self else { return }
                var snapshot = CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>.DiffableSnapshot()
                let allSectsions = datas.map({ $0.section })
                snapshot.appendSections(allSectsions)
                for eachSection in datas {
                    snapshot.appendItems(eachSection.items, toSection: eachSection.section)
                }
                self.dataSource?.apply(snapshot, animatingDifferences: true)
            }
        }
        controller.appendDataConfig = { [weak self] datas in
            DispatchQueue.global().async {
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()
                datas.forEach { eachData in
                    snapshot.appendItems(eachData.items, toSection: eachData.section)
                }
                self.dataSource?.apply(snapshot, animatingDifferences: true)
            }
        }
        controller.appendBeforeConfig = { [weak self] datas, before in
            DispatchQueue.global().async {
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()
                snapshot.insertItems(datas, beforeItem: before)
                self.dataSource?.apply(snapshot, animatingDifferences: true)
            }
        }
        controller.removeDataConfig = { [weak self] datas in
            DispatchQueue.global().async {
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()
                snapshot.deleteItems(datas)
                self.dataSource?.apply(snapshot, animatingDifferences: true)
            }
        }
        controller.modifyDataConfig = { [weak self] items in
            DispatchQueue.global().async {
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()
                snapshot.reloadItems(items)
                self.dataSource?.apply(snapshot, animatingDifferences: true)
            }
        }
        controller.reloadSectionConfig = { [weak self] sections in
            DispatchQueue.global().async {
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()
                snapshot.reloadSections(sections)
                self.dataSource?.apply(snapshot, animatingDifferences: true)
            }
        }
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

public extension CustomDiffableSectionData {
    
    static func controller() -> CustomDiffableCollectionDataController<Self> {
        return .init()
    }
}

public class CustomDiffableCollectionDataController<SectionData: CustomDiffableSectionData> {
    public func applyData(datas: [SectionData]) -> Void {
        self.applyDataConfig(datas)
    }
    public func appendData(datas: [SectionData]) -> Void {
        self.appendDataConfig(datas)
    }
    public func appendBefore(datas: [SectionData.ItemIdentifier], before item: SectionData.ItemIdentifier) -> Void {
        self.appendBeforeConfig(datas, item)
    }
    public func modifyData(datas: [SectionData.ItemIdentifier]) -> Void {
        self.modifyDataConfig(datas)
    }
    
    public func removeData(datas: [SectionData.ItemIdentifier]) -> Void {
        self.removeDataConfig(datas)
    }
    
    public func reloadSection(section: [SectionData.SectionIdentifier]) -> Void {
        self.reloadSectionConfig(section)
    }
    
    var applyDataConfig: ([SectionData]) -> Void = { _ in }
    var appendDataConfig: ([SectionData]) -> Void = { _ in }
    var appendBeforeConfig: ([SectionData.ItemIdentifier], SectionData.ItemIdentifier) -> Void = { _, _ in }
    var modifyDataConfig: ([SectionData.ItemIdentifier]) -> Void = { _ in }
    var reloadSectionConfig: ([SectionData.SectionIdentifier]) -> Void = { _ in }
    var removeDataConfig: ([SectionData.ItemIdentifier]) -> Void = { _ in }
}

public struct CustomDiffableCollectionView<SectionIdentifier: Hashable, ItemIdentifier: Hashable, SectionData: CustomDiffableSectionData>: UIViewRepresentable where SectionData.SectionIdentifier == SectionIdentifier, SectionData.ItemIdentifier == ItemIdentifier {
    
    public typealias UIViewType = CustomDiffableCollectionUIView<SectionIdentifier, ItemIdentifier>
    
    let dataHelper: CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>
    var customLayout: UICollectionViewLayout? = nil
    var needReload: Bool = false
    var collectionConfig: (UICollectionView) -> Void = {_ in }
    
    @Binding var data: [SectionData]
    weak var controller: CustomDiffableCollectionDataController<SectionData>? = nil
    
    private let updateQueue = DispatchQueue(label: "CustomDiffableDataUpdateQueue", qos: .background)
    
    public init(data: Binding<[SectionData]>, config: @escaping (UICollectionView) -> Void = {_ in }, layout: UICollectionViewLayout? = nil, cell: @escaping (UICollectionView, IndexPath, ItemIdentifier) -> AnyView, header: ((UICollectionView, String, IndexPath) -> AnyView?)? = nil, footer: ((UICollectionView, String, IndexPath) -> AnyView?)? = nil) {
        self.collectionConfig = config
        self.customLayout = layout
        self.dataHelper = CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>()
        self.dataHelper.customCellGenerator = cell
        self.dataHelper.customHeaderGenerator = header
        self.dataHelper.customFooterGenerator = footer
        self._data = data
    }
    
    public init(controller: CustomDiffableCollectionDataController<SectionData>, config: @escaping (UICollectionView) -> Void = {_ in }, layout: UICollectionViewLayout? = nil, cell: @escaping (UICollectionView, IndexPath, ItemIdentifier) -> AnyView, header: ((UICollectionView, String, IndexPath) -> AnyView?)? = nil, footer: ((UICollectionView, String, IndexPath) -> AnyView?)? = nil) {
        self.collectionConfig = config
        self.customLayout = layout
        self.dataHelper = CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>()
        self.dataHelper.customCellGenerator = cell
        self.dataHelper.customHeaderGenerator = header
        self.dataHelper.customFooterGenerator = footer
        self._data = .constant([])
        self.controller = controller
    }
    
    public func makeUIView(context: Context) -> CustomDiffableCollectionUIView<SectionIdentifier, ItemIdentifier> {
        let uiView = CustomDiffableCollectionUIView(data: self.dataHelper, config: self.collectionConfig)
        uiView.customLayout = self.customLayout
        if let getController = self.controller {
            uiView.configController(controller: getController)
        }
        return uiView
    }
    
    public func updateUIView(_ uiView: CustomDiffableCollectionUIView<SectionIdentifier, ItemIdentifier>, context: Context) {
        if self.needReload {
            uiView.customLayout = self.customLayout
        }
        if self.controller == nil {
            self.applyData(dataHelper: uiView.data)
        }
    }
    
    func applyData(dataHelper: CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>) {
        let allData = self.data
        self.updateQueue.async {
            var snapshot = CustomDiffableCollectionDataSourceHelper<SectionIdentifier, ItemIdentifier>.DiffableSnapshot()
            let allSectsions = allData.map({ $0.section })
            snapshot.appendSections(allSectsions)
            for eachSection in allData {
                snapshot.appendItems(eachSection.items, toSection: eachSection.section)
            }
            dataHelper.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    public func customLayout(_ customLayout: UICollectionViewLayout?) -> Self {
        var copy = self
        copy.customLayout = customLayout
        copy.needReload = true
        return copy
    }
    
    public func contextMenu(_ configuration: @escaping (UICollectionView, [IndexPath], CGPoint) -> UIContextMenuConfiguration?) -> Self {
        let copy = self
        copy.dataHelper.contextMenuConfiguration = configuration
        return copy
    }
    
    public func contextMenuHighlightPreview(_ preview: @escaping (UICollectionView, UIContextMenuConfiguration, IndexPath) -> UITargetedPreview?) -> Self {
        let copy = self
        copy.dataHelper.contextMenuHighlightPreviewConfiguration = preview
        return copy
    }
    
    public func contextMenuDismissalPreview(_ preview: @escaping (UICollectionView, UIContextMenuConfiguration, IndexPath) -> UITargetedPreview?) -> Self {
        let copy = self
        copy.dataHelper.contextMenuDismissalPreviewConfiguration = preview
        return copy
    }
    
}


