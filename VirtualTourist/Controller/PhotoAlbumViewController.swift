//PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Hamna Usmani on 7/2/18.
//  Copyright © 2018 Hamna Usmani. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    var dataController: DataController!
    var pin: Pin!
    
    @IBOutlet weak var newCollectionBtn: UIBarButtonItem!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageLabel: UILabel!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    // Keep the changes. will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    // Setting up FetchedResultsController - To handle data for store and view
    func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "pin", ascending: true)
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        setUpFetchedResultsController()
        
        //No images stored for current pin
        //Getting images from server
        if(pin.photos?.count == 0){
            getLocationPhotos()
            newCollectionBtn.isEnabled = false
        }else{
            activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let space:CGFloat = 5.0
        let dimensionWidth = (view.frame.size.width - (2 * space))/3
        let dimensionHeight = (view.frame.size.height - (2 * space))/3
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimensionWidth, height: dimensionHeight)
    }
    
    //Getting photos associated with a pin from server
    func getLocationPhotos(){
        FlikrClient.sharedInstance().getPhotosFromFlikr(latitude: pin.latitude, longitude: pin.longitude) { (count, results, errorString) in
            performUIUpdatesOnMain {
                guard errorString == nil else {
                    self.imageLabel.text = errorString
                    return
                }
                if count == 0 {
                    self.imageLabel.text = "No Pictures Found."
                } else {
                    //Generating photo object for each result
                    for result in results!{
                        let photo = Photo(context: self.dataController.viewContext)
                        photo.url = result[FlikrClient.FlickrResponseKeys.MediumURL] as? String
                        photo.pin = self.pin
                    }
                    //Saving photos to store
                    self.dataController.viewContext.perform {
                        try? self.dataController.viewContext.save()
                        
                        //Downloading images from URL
                        DownloadImage.downloadImagesForUrl(self.fetchedResultsController.fetchedObjects!, self.dataController){
                            self.activityIndicator.stopAnimating()
                            self.newCollectionBtn.isEnabled = true
                            
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    @IBAction func getNewCollectionBtnTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        newCollectionBtn.isEnabled = false
        
        for photo in fetchedResultsController.fetchedObjects! {
            dataController.viewContext.delete(photo)
            try? dataController.viewContext.save()
        }
        
        getLocationPhotos()
    }
    
    
}


extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - Collection view data source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.defaultReuseIdentifier, for: indexPath) as! ImageCell
        
        cell.imageActivityIndicator.hidesWhenStopped = true
        cell.imageActivityIndicator.startAnimating()
        
        let photo = fetchedResultsController.object(at: indexPath)
        if let imageData = photo.image {
            cell.imageView.image = UIImage(data: imageData)
            cell.imageActivityIndicator.stopAnimating()
        }
        return cell
    }
    
    // MARK: - Action for deleting a cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataController.viewContext.perform {
            let photoToBeDeleted = self.fetchedResultsController.object(at: indexPath)
            self.dataController.viewContext.delete(photoToBeDeleted)
            try? self.dataController.viewContext.save()
        }
        
        
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            //Insert
            for indexPath in self.insertedIndexPaths {
                collectionView.insertItems(at: [indexPath])
            }
            //Delete
            for indexPath in self.deletedIndexPaths {
                collectionView.deleteItems(at: [indexPath])
            }
            //Update
            for indexPath in self.updatedIndexPaths {
                collectionView.reloadItems(at: [indexPath])
            }
        }, completion: nil)
    }
    
}


