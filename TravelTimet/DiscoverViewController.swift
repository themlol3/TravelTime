import UIKit
import Firebase
import SDWebImage

class DiscoverViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var places: [(name: String, latitude: Double, longitude: Double, imageURL: String?)] = []

    let apiKey = "AIzaSyBLuLFlExqb7LThSE8Kzsrm6UaoD-gl3kw"
    let cx = "a69e6046c4edc4d9f"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Discover"

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PlaceCell")
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        fetchPlaces()
    }

    func fetchPlaces() {
        
        let databaseRef = Database.database(url: "https://traveltime-628dc-default-rtdb.europe-west1.firebasedatabase.app").reference().child("places")
        databaseRef.observe(.value) { snapshot in
            self.places.removeAll()

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let name = dict["name"] as? String,
                   let latitude = dict["latitude"] as? Double,
                   let longitude = dict["longitude"] as? Double {
                    
                    self.fetchImageURL(for: name) { imageURL in
                        self.places.append((name: name, latitude: latitude, longitude: longitude, imageURL: imageURL))
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }

    func fetchImageURL(for placeName: String, completion: @escaping (String?) -> Void) {
        let searchQuery = placeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/customsearch/v1?q=\(searchQuery)&cx=\(cx)&key=\(apiKey)&searchType=image&num=1"

        guard let url = URL(string: urlString) else {
            print("prb URL: \(urlString)")
            completion(nil)
            return
        }

        print("Fetching image from URL: \(urlString)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed image: \(error.localizedDescription)")
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
                        print("Image not found: \(link)")
                        completion(link)
                    } else {
                        print("No items in")
                        completion(nil)
                    }
                }
            } catch {
                print("Fail JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }

        task.resume()
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath)

        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }

        let place = places[indexPath.item]

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height * 0.7))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)

        if let imageURL = place.imageURL, let url = URL(string: imageURL) {
            imageView.sd_setImage(with: url, completed: nil)
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
        let place = places[indexPath.item]
        let placeVC = PlaceViewController()
        placeVC.place = place
        navigationController?.pushViewController(placeVC, animated: true)
    }
    
}
