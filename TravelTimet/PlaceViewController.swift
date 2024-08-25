import UIKit
import Firebase
import SDWebImage

class PlaceViewController: UIViewController {

    var place: (name: String, latitude: Double, longitude: Double, imageURL: String?)?
    var databaseRef: DatabaseReference!

    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let imageView = UIImageView()
    let nameLabel = UILabel()
    
    let openHoursContainer = UIView()
    let reviewsContainer = UIView()
    let wikipediaContainer = UIView()
    
    let openHoursScrollView = UIScrollView()
    let reviewsScrollView = UIScrollView()
    let wikipediaScrollView = UIScrollView()
    
    let openHoursLabel = UILabel()
    let reviewsLabel = UILabel()
    let wikipediaLabel = UILabel()
    
    let bookmarksButton = UIButton()
    let nextDestinationLabel = UILabel()
    let recommendedButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        configureView()
    }

    func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        openHoursContainer.translatesAutoresizingMaskIntoConstraints = false
        openHoursContainer.backgroundColor = .yellow
        openHoursContainer.layer.cornerRadius = 8
        openHoursContainer.clipsToBounds = true
        
        reviewsContainer.translatesAutoresizingMaskIntoConstraints = false
        reviewsContainer.backgroundColor = .yellow
        reviewsContainer.layer.cornerRadius = 8
        reviewsContainer.clipsToBounds = true
        
        wikipediaContainer.translatesAutoresizingMaskIntoConstraints = false
        wikipediaContainer.backgroundColor = .yellow
        wikipediaContainer.layer.cornerRadius = 8
        wikipediaContainer.clipsToBounds = true
        let wikipediaTapGesture = UITapGestureRecognizer(target: self, action: #selector(openWikipedia))
        wikipediaContainer.addGestureRecognizer(wikipediaTapGesture)
        wikipediaContainer.isUserInteractionEnabled = true
        
        openHoursScrollView.translatesAutoresizingMaskIntoConstraints = false
        reviewsScrollView.translatesAutoresizingMaskIntoConstraints = false
        wikipediaScrollView.translatesAutoresizingMaskIntoConstraints = false

        openHoursLabel.numberOfLines = 0
        openHoursLabel.translatesAutoresizingMaskIntoConstraints = false
        
        reviewsLabel.numberOfLines = 0
        reviewsLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewsLabel.text = "Reviews"
        
        wikipediaLabel.numberOfLines = 0
        wikipediaLabel.translatesAutoresizingMaskIntoConstraints = false
        wikipediaLabel.text = "Visit Wikipedia"

        bookmarksButton.setTitle("Add to Bookmarks", for: .normal)
        bookmarksButton.setTitleColor(.systemBlue, for: .normal)
        bookmarksButton.translatesAutoresizingMaskIntoConstraints = false
        bookmarksButton.addTarget(self, action: #selector(addToBookmarks), for: .touchUpInside)
        
        nextDestinationLabel.textAlignment = .center
        nextDestinationLabel.font = UIFont.systemFont(ofSize: 16)
        nextDestinationLabel.translatesAutoresizingMaskIntoConstraints = false
        nextDestinationLabel.text = "Recommended Next Destination"
        nextDestinationLabel.isHidden = false
        
        recommendedButton.setTitleColor(.black, for: .normal)
        recommendedButton.backgroundColor = .yellow
        recommendedButton.layer.cornerRadius = 8
        recommendedButton.clipsToBounds = true
        recommendedButton.translatesAutoresizingMaskIntoConstraints = false
        recommendedButton.addTarget(self, action: #selector(openRecommendedPlace), for: .touchUpInside)
        recommendedButton.isHidden = true

        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(openHoursContainer)
        contentView.addSubview(reviewsContainer)
        contentView.addSubview(wikipediaContainer)
        contentView.addSubview(bookmarksButton)
        contentView.addSubview(nextDestinationLabel)
        contentView.addSubview(recommendedButton)
        
        openHoursContainer.addSubview(openHoursScrollView)
        reviewsContainer.addSubview(reviewsScrollView)
        wikipediaContainer.addSubview(wikipediaScrollView)
        
        openHoursScrollView.addSubview(openHoursLabel)
        reviewsScrollView.addSubview(reviewsLabel)
        wikipediaScrollView.addSubview(wikipediaLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            openHoursContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            openHoursContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            openHoursContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.28),
            openHoursContainer.heightAnchor.constraint(equalToConstant: 60),

            reviewsContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            reviewsContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            reviewsContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.28),
            reviewsContainer.heightAnchor.constraint(equalToConstant: 60),

            wikipediaContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            wikipediaContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            wikipediaContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.28),
            wikipediaContainer.heightAnchor.constraint(equalToConstant: 60),

            openHoursScrollView.leadingAnchor.constraint(equalTo: openHoursContainer.leadingAnchor),
            openHoursScrollView.trailingAnchor.constraint(equalTo: openHoursContainer.trailingAnchor),
            openHoursScrollView.topAnchor.constraint(equalTo: openHoursContainer.topAnchor),
            openHoursScrollView.bottomAnchor.constraint(equalTo: openHoursContainer.bottomAnchor),

            reviewsScrollView.leadingAnchor.constraint(equalTo: reviewsContainer.leadingAnchor),
            reviewsScrollView.trailingAnchor.constraint(equalTo: reviewsContainer.trailingAnchor),
            reviewsScrollView.topAnchor.constraint(equalTo: reviewsContainer.topAnchor),
            reviewsScrollView.bottomAnchor.constraint(equalTo: reviewsContainer.bottomAnchor),

            wikipediaScrollView.leadingAnchor.constraint(equalTo: wikipediaContainer.leadingAnchor),
            wikipediaScrollView.trailingAnchor.constraint(equalTo: wikipediaContainer.trailingAnchor),
            wikipediaScrollView.topAnchor.constraint(equalTo: wikipediaContainer.topAnchor),
            wikipediaScrollView.bottomAnchor.constraint(equalTo: wikipediaContainer.bottomAnchor),

            openHoursLabel.leadingAnchor.constraint(equalTo: openHoursScrollView.leadingAnchor, constant: 8),
            openHoursLabel.trailingAnchor.constraint(equalTo: openHoursScrollView.trailingAnchor, constant: -8),
            openHoursLabel.topAnchor.constraint(equalTo: openHoursScrollView.topAnchor, constant: 8),
            openHoursLabel.bottomAnchor.constraint(equalTo: openHoursScrollView.bottomAnchor, constant: -8),

            reviewsLabel.leadingAnchor.constraint(equalTo: reviewsScrollView.leadingAnchor, constant: 8),
            reviewsLabel.trailingAnchor.constraint(equalTo: reviewsScrollView.trailingAnchor, constant: -8),
            reviewsLabel.topAnchor.constraint(equalTo: reviewsScrollView.topAnchor, constant: 8),
            reviewsLabel.bottomAnchor.constraint(equalTo: reviewsScrollView.bottomAnchor, constant: -8),

            wikipediaLabel.leadingAnchor.constraint(equalTo: wikipediaScrollView.leadingAnchor, constant: 8),
            wikipediaLabel.trailingAnchor.constraint(equalTo: wikipediaScrollView.trailingAnchor, constant: -8),
            wikipediaLabel.topAnchor.constraint(equalTo: wikipediaScrollView.topAnchor, constant: 8),
            wikipediaLabel.bottomAnchor.constraint(equalTo: wikipediaScrollView.bottomAnchor, constant: -8),

            bookmarksButton.topAnchor.constraint(equalTo: openHoursContainer.bottomAnchor, constant: 20),
            bookmarksButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            nextDestinationLabel.topAnchor.constraint(equalTo: bookmarksButton.bottomAnchor, constant: 20),
            nextDestinationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            recommendedButton.topAnchor.constraint(equalTo: nextDestinationLabel.bottomAnchor, constant: 10),
            recommendedButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            recommendedButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            recommendedButton.heightAnchor.constraint(equalToConstant: 40),

            recommendedButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    @objc func addToBookmarks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let databaseRef = Database.database(url: "https://traveltime-628dc-default-rtdb.europe-west1.firebasedatabase.app").reference()
        let bookmarksRef = databaseRef.child("users").child(userId).child("bookmarks")

        if let place2 = place {
            let bookmarkData: [String: Any] = [
                "name": place2.name,
                "latitude": place2.latitude,
                "longitude": place2.longitude,
                "imageURL": place2.imageURL ?? ""
            ]
            
            bookmarksRef.childByAutoId().setValue(bookmarkData) { error, _ in
                if let error = error {
                    print("Failed to add to bookmarks: \(error.localizedDescription)")
                } else {
                    print("Successfully added to bookmarks")
                }
            }
        }
    }

    func configureView() {
        guard let place = place else { return }

        nameLabel.text = place.name

        if let urlString = place.imageURL, let url = URL(string: urlString) {
            imageView.sd_setImage(with: url, completed: nil)
        } else {
            print("No image URL available for place: \(place.name)")
        }

        let databaseRef = Database.database(url: "https://traveltime-628dc-default-rtdb.europe-west1.firebasedatabase.app").reference().child("places")

        databaseRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let data = childSnapshot.value as? [String: Any] {

                        if let name = data["name"] as? String, name == place.name {
                            let totalScore = data["totalScore"] as? Double ?? 0.0
                            let reviewCount = data["reviewCount"] as? Int ?? 0
                            self.fetchPlaceDetails(placeName: place.name)
                        }
                    }
                }
            } else {
                print("No data found for place: \(place.name)")
            }
        }

        fetchRecommendedDestination()
    }

    func fetchPlaceDetails(placeName: String) {
        let apiKey = "AIzaSyBLuLFlExqb7LThSE8Kzsrm6UaoD-gl3kw"
        let encodedPlaceName = placeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? placeName
        let findPlaceUrlString = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=\(encodedPlaceName)&inputtype=textquery&fields=place_id&key=\(apiKey)"
        print("URL for Place ID: \(findPlaceUrlString)")

        guard let findPlaceUrl = URL(string: findPlaceUrlString) else {
            print("Invalid URL: \(findPlaceUrlString)")
            return
        }

        let findPlaceTask = URLSession.shared.dataTask(with: findPlaceUrl) { data, response, error in
            if let error = error {
                print("Failed ID: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data API")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let placeId = firstCandidate["place_id"] as? String {
                    print("Place ID: \(placeId)")
                    
                    self.fetchDetailedPlaceInfoById(placeId: placeId, apiKey: apiKey)
                } else {
                    print("No ID")
                }
            } catch {
                print("Failed JSON: \(error.localizedDescription)")
            }
        }

        findPlaceTask.resume()
    }
    
    func fetchDetailedPlaceInfoById(placeId: String, apiKey: String) {
        let detailsUrlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=name,opening_hours,formatted_address,price_level,rating&key=\(apiKey)"
        print("URLPlace Details: \(detailsUrlString)")
        
        guard let detailsUrl = URL(string: detailsUrlString) else {
            print("Invalid URL: \(detailsUrlString)")
            return
        }
        
        let detailsTask = URLSession.shared.dataTask(with: detailsUrl) { data, response, error in
            if let error = error {
                print("Failed G info: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data G P API")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let result = json["result"] as? [String: Any] {
                    print("Received detailed JSON: \(result)")
                    
                    DispatchQueue.main.async {
                        if let openingHours = result["opening_hours"] as? [String: Any],
                           let weekdayText = openingHours["weekday_text"] as? [String] {
                            
                            let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1
                            
                            if todayIndex >= 0 && todayIndex < weekdayText.count {
                                let todayHours = weekdayText[todayIndex]
                                self.openHoursLabel.text = todayHours
                            } else {
                                self.openHoursLabel.text = "Open Hours: N/A"
                            }

                            if let openNow = openingHours["open_now"] as? Bool {
                                self.openHoursLabel.text = (openNow ? "Open" : "Closed") + " - " + self.openHoursLabel.text!
                            } else {
                                self.openHoursLabel.text = "Open Hours: N/A"
                            }
                            
                        } else {
                            self.openHoursLabel.text = "Open Hours: N/A"
                        }

                        if let rating = result["rating"] as? Double {
                            self.reviewsLabel.text = "Rating: \(rating)"
                        } else {
                            self.reviewsLabel.text = "Rating: N/A"
                        }

                        print("Updated labels with today's opening hours and place details data")
                    }
                } else {
                    print("No result found in response")
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
            }
        }
        
        detailsTask.resume()
    }

    func fetchRecommendedDestination() {
        guard let currentPlace = place else { return }
        
        let databaseRef = Database.database(url: "https://traveltime-628dc-default-rtdb.europe-west1.firebasedatabase.app").reference().child("places")
        
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                var closestPlace: (name: String, distance: Double)?
                
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let data = childSnapshot.value as? [String: Any],
                       let name = data["name"] as? String,
                       let latitude = data["latitude"] as? Double,
                       let longitude = data["longitude"] as? Double,
                       name != currentPlace.name {
                        
                        let distance = self.calculateDistance(from: (currentPlace.latitude, currentPlace.longitude), to: (latitude, longitude))
                        
                        if closestPlace == nil || distance < closestPlace!.distance {
                            closestPlace = (name, distance)
                        }
                    }
                }
                
                if let closestPlace = closestPlace {
                    self.recommendedButton.setTitle(closestPlace.name, for: .normal)
                    self.recommendedButton.isHidden = false
                } else {
                    self.recommendedButton.isHidden = true
                }
            } else {
                print("No databasedestination.")
            }
        }
    }

    func calculateDistance(from: (Double, Double), to: (Double, Double)) -> Double {
        let lat1 = from.0
        let lon1 = from.1
        let lat2 = to.0
        let lon2 = to.1
        
        let dLat = (lat2 - lat1).degreesToRadians
        let dLon = (lon2 - lon1).degreesToRadians
        
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1.degreesToRadians) * cos(lat2.degreesToRadians) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let radius = 6371000.0
        
        return radius * c
    }

    @objc func openRecommendedPlace() {
        guard let placeName = recommendedButton.title(for: .normal) else { return }

        let databaseRef = Database.database(url: "https://traveltime-628dc-default-rtdb.europe-west1.firebasedatabase.app").reference().child("places")

        databaseRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let data = childSnapshot.value as? [String: Any],
                       let name = data["name"] as? String,
                       name == placeName {

                        let latitude = data["latitude"] as? Double ?? 0.0
                        let longitude = data["longitude"] as? Double ?? 0.0
                        
                        self.fetchImageURL(for: placeName) { imageURL in
                            if let imageURL = imageURL {
                                DispatchQueue.main.async {
                                    let newPlaceVC = PlaceViewController()
                                    newPlaceVC.place = (name: placeName, latitude: latitude, longitude: longitude, imageURL: imageURL)
                                    self.navigationController?.pushViewController(newPlaceVC, animated: true)
                                }
                            } else {
                                print("Image URL could not be fetched for the place: \(placeName)")
                            }
                        }
                        return
                    }
                }
                print("Place with name \(placeName) not found in Firebase.")
            } else {
                print("No places found in the database.")
            }
        }
    }

    
    func fetchImageURL(for placeName: String, completion: @escaping (String?) -> Void) {
        let searchQuery = placeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/customsearch/v1?q=\(searchQuery)&cx=\("a69e6046c4edc4d9f")&key=\("AIzaSyBLuLFlExqb7LThSE8Kzsrm6UaoD-gl3kw")&searchType=image&num=1"

        guard let url = URL(string: urlString) else {
            print("Inv URL: \(urlString)")
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed image URL: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data G API")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let items = json["items"] as? [[String: Any]],
                   let firstItem = items.first,
                   let link = firstItem["link"] as? String {
                    completion(link)
                } else {
                    print("No itemsresponse")
                    completion(nil)
                }
            } catch {
                print("F JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }

        task.resume()
    }



    @objc func openWikipedia() {
        guard let place = place else { return }
        let searchQuery = place.name.replacingOccurrences(of: " ", with: "_")
        if let url = URL(string: "https://en.wikipedia.org/wiki/\(searchQuery)") {
            UIApplication.shared.open(url)
        }
    }

    @objc func openGoogleReviews() {
        guard let place = place else { return }
        let searchQuery = place.name.replacingOccurrences(of: " ", with: "+")
        if let url = URL(string: "https://www.google.com/search?q=\(searchQuery)+reviews") {
            UIApplication.shared.open(url)
        }
    }
}

extension Double {
    var degreesToRadians: Double {
        return self * .pi / 180
    }
}
