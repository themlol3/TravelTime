import UIKit
import Firebase
import SDWebImage
import CoreLocation

class NearbyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var nearbyPlaces: [(name: String, latitude: Double, longitude: Double, distance: Double, imageURL: String?)] = []
    var currentLocation: CLLocation?

    let apiKey = "AIzaSyBLuLFlExqb7LThSE8Kzsrm6UaoD-gl3kw"
    let cx = "a69e6046c4edc4d9f"
    let locationManager = CLLocationManager()
    let databaseRef = Database.database(url: "https://traveltime-628dc-default-rtdb.europe-west1.firebasedatabase.app").reference().child("places")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Nearby"

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "NearbyCell")
        collectionView.backgroundColor = .white

        view.addSubview(collectionView)

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func fetchNearbyPlaces() {
        guard let currentLocation = currentLocation else {
            print("p1")
            return
        }
        
        databaseRef.observe(.value) { snapshot in
            self.nearbyPlaces.removeAll()
            var fetchImageTasks: [DispatchWorkItem] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let name = data["name"] as? String,
                   let latitude = data["latitude"] as? Double,
                   let longitude = data["longitude"] as? Double {

                    let placeLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let distance = currentLocation.distance(from: placeLocation) / 1000.0
                    
                    if distance <= 100 {
                        let fetchImageTask = DispatchWorkItem {
                            self.fetchImageURL(for: name) { imageURL in
                                self.nearbyPlaces.append((name: name, latitude: latitude, longitude: longitude, distance: distance, imageURL: imageURL))
                                
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                        fetchImageTasks.append(fetchImageTask)
                    }
                }
            }
            
            for task in fetchImageTasks {
                DispatchQueue.global().async(execute: task)
            }
        }
    }

    func fetchImageURL(for placeName: String, completion: @escaping (String?) -> Void) {
        let searchQuery = placeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/customsearch/v1?q=\(searchQuery)&cx=\(cx)&key=\(apiKey)&searchType=image&num=1"

        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        print("Fetching image from URL: \(urlString)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Fail image URL: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data Google API")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Response JSON: \(json)")

                    if let items = json["items"] as? [[String: Any]],
                       let firstItem = items.first,
                       let link = firstItem["link"] as? String {
                        print("Image URL found: \(link)")
                        completion(link)
                    } else {
                        print("No items found in response")
                        completion(nil)
                    }
                }
            } catch {
                print("Failed JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }

        task.resume()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbyPlaces.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyCell", for: indexPath)

        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }

        let place = nearbyPlaces[indexPath.item]

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height * 0.7))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)

        if let imageURL = place.imageURL, let url = URL(string: imageURL) {
            imageView.sd_setImage(with: url, completed: nil)
        } else {
            imageView.image = UIImage(named: "placeholder")
        }

        let nameLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY, width: cell.frame.width, height: cell.frame.height * 0.3))
        nameLabel.text = place.name
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        cell.contentView.addSubview(nameLabel)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width / 2) - 10, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let place = nearbyPlaces[indexPath.item]
        let placeVC = PlaceViewController()
        placeVC.place = (name: place.name, latitude: place.latitude, longitude: place.longitude, imageURL: place.imageURL)
        navigationController?.pushViewController(placeVC, animated: true)
    }
}

extension NearbyViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = CLLocation(latitude: 32.0853, longitude: 34.7818)
            //currentLocation = location I disabled it because it would give me location in califonia on the simulator. So I made tlv a default location

            fetchNearbyPlaces()
            locationManager.stopUpdatingLocation()
        }
    }

}
