/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import E5Data

import UniformTypeIdentifiers

class ImageGridView: NSView{
    
    static var defaultGridSize: CGFloat = 200
    static var gridSizeFactors : Array<CGFloat> = [0.5, 0.75, 1.0, 1.5, 2.0]
    
    var images = Array<Image>()
    
    var menuView = ImageGridMenuView()
    let scrollView = NSScrollView()
    let collectionView = NSCollectionView()
    let layout = NSCollectionViewGridLayout()
    
    var gridSize: CGFloat{
        ImageGridView.defaultGridSize * ImageGridView.gridSizeFactors[MacPreferences.macshared.gridSizeFactorIndex]
    }
    
    override func setupView() {
        addSubviewWithAnchors(menuView, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor)
        menuView.setupView()
        menuView.delegate = self
        addSubviewWithAnchors(scrollView, top: topAnchor, leading: menuView.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        collectionView.allowsEmptySelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.isSelectable = true
        collectionView.delegate = self
        collectionView.dataSource = self
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.documentView = collectionView
        layout.minimumLineSpacing = Insets.smallInset
        layout.minimumInteritemSpacing = Insets.smallInset
        let gridSize = gridSize
        layout.minimumItemSize = CGSize(width: gridSize * 0.75, height: gridSize * 0.75)
        layout.minimumItemSize = CGSize(width: gridSize * 1.25, height: gridSize * 1.25)
        collectionView.collectionViewLayout = layout
        images.append(contentsOf: AppData.shared.locations.images)
        collectionView.reloadData()
    }
    
    func updateView(){
        collectionView.removeAllSubviews()
        updateData()
    }
    
    func updateData(){
        images.removeAll()
        images.append(contentsOf: AppData.shared.locations.images)
        collectionView.reloadData()
    }
    
    func getSelectedImages() -> Array<Image>{
        var arr = Array<Image>()
        if collectionView.selectionIndexPaths.isEmpty{
            arr.append(contentsOf: images )
        }
        else{
            for path in collectionView.selectionIndexPaths{
                arr.append(images[path.item])
            }
        }
        return arr
    }
    
    func showImage(_ image: Image){
        MainViewController.instance.showImage(image)
    }
    
    func increaseImageSize() {
        if MacPreferences.macshared.gridSizeFactorIndex < ImageGridView.gridSizeFactors.count - 1{
            MacPreferences.macshared.gridSizeFactorIndex += 1
            let gridSize = gridSize
            layout.minimumItemSize = CGSize(width: gridSize * 0.75, height: gridSize * 0.75)
            layout.minimumItemSize = CGSize(width: gridSize * 1.25, height: gridSize * 1.25)
        }
    }
    
    func decreaseImageSize() {
        if MacPreferences.macshared.gridSizeFactorIndex > 0{
            MacPreferences.macshared.gridSizeFactorIndex -= 1
            layout.minimumItemSize = CGSize(width: gridSize * 0.75, height: gridSize * 0.75)
            layout.minimumItemSize = CGSize(width: gridSize * 1.25, height: gridSize * 1.25)
        }
    }
    
}

extension ImageGridView: NSCollectionViewDataSource{
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let image = images[indexPath.item]
        if image.selected{
            collectionView.selectionIndexPaths.insert(indexPath)
        }
        let item = ImageGridItem(image: image, gridView: collectionView.delegate as? ImageGridView)
        item.isSelected = image.selected
        item.setHighlightState()
        item.delegate = self
        return item
    }
    
}

extension ImageGridView: NSCollectionViewDelegate{
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths{
            if let item = collectionView.item(at: indexPath) as? ImageGridItem{
                item.select(true)
                print("selected \(item.image.fileName)")
                item.setHighlightState()
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths{
            if let item = collectionView.item(at: indexPath) as? ImageGridItem{
                item.select(false)
                print("deselected \(item.image.fileName)")
                item.setHighlightState()
            }
        }
    }
    
}

extension ImageGridView: ImageGridMenuDelegate{
    
    func toggleSelectAll() {
        if images.allSelected{
            images.deselectAll()
        }
        else{
            images.selectAll()
        }
        collectionView.reloadData()
    }
    
    func showSelected() {
        let selected = getSelectedImages()
        if !selected.isEmpty{
            MainViewController.instance.showImages(selected)
        }
    }
    
    func importImages() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [UTType.image]
        panel.allowsMultipleSelection = true
        panel.directoryURL = FileManager.imagesURL
        if panel.runModal() == .OK, !panel.urls.isEmpty{
            var imagesWithoutCoordinates = 0
            for url in panel.urls{
                if let data = FileManager.default.readFile(url: url){
                    let metaData = ImageMetaData()
                    metaData.readData(data: data)
                    if let coordinate = metaData.coordinate{
                        let image = Image()
                        FileManager.default.copyFile(fromURL: url, toURL: image.fileURL)
                        image.metaData = metaData
                        if let location = AppData.shared.getLocation(coordinate: coordinate){
                            location.addItem(item: image)
                        }
                        else{
                            let location = Location(coordinate: coordinate)
                            location.addItem(item: image)
                            AppData.shared.locations.append(location)
                        }
                    }
                    else{
                        imagesWithoutCoordinates += 1
                    }
                }
            }
            AppData.shared.save()
            MainViewController.instance.locationsChanged()
            if imagesWithoutCoordinates > 0{
                MainWindowController.instance.mainViewController.showInfo(text: "imagesNotImported".localize(param: String(imagesWithoutCoordinates)))
            }
        }
    }
    
    func exportSelected() {
        let selected = getSelectedImages()
        MainViewController.instance.exportImages(selected)
    }
    
}

extension ImageGridView: ImageGridItemDelegate{
    
    func showImageFullSize(_ image: Image) {
        MainViewController.instance.showImage(image)
    }
    
    func exportImage(_ image: Image) {
        MainViewController.instance.exportImage(image)
    }
    
}





