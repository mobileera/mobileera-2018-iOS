import UIKit
import Foundation
import Firebase

extension Decodable {
    /// Initialize from JSON Dictionary. Return nil on failure
    init?(dictionary value: [String:Any]){
        
        guard JSONSerialization.isValidJSONObject(value) else { return nil }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []) else { return nil }
        
        guard let newValue = try? JSONDecoder().decode(Self.self, from: jsonData) else { return nil }
        self = newValue
    }
}

class SpeakersViewController: BaseViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.4)
        tableView.estimatedRowHeight = 76
        return tableView
    }()

    var database: Firestore!
    
    private var speakersSource: SpeakersSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        database = Firestore.firestore()
        database.settings = settings

        title = R.string.localizable.speakers()
        
        speakersSource = SpeakersSource(self, speakers: [])
        tableView.dataSource = speakersSource
        tableView.delegate = speakersSource
        tableView.register(SpeakerTableViewCell.nib, forCellReuseIdentifier: SpeakerTableViewCell.key)
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.info(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(showInfo))

        loadData()
    }

    @objc func showInfo() {
        let alertController = UIAlertController.infoAlert(from: navigationItem.rightBarButtonItem)
        present(alertController, animated: true, completion: nil)
    }

    private func loadData() {
        database.collection("speakers").getDocuments { speakersQuerySnapshot, speakersError in
            let speakersDocuments = speakersQuerySnapshot?.documents ?? [QueryDocumentSnapshot]()
            var speakers = [Speaker]()
            for speakerDocument in speakersDocuments {
                guard let speakerData = try? JSONSerialization.data(withJSONObject: speakerDocument.data(), options: []) else { fatalError() }
                if let speaker = try? JSONDecoder().decode(Speaker.self, from: speakerData) {
                    speaker.id = speakerDocument.documentID
                    speakers.append(speaker)
                }
            }

            self.speakersSource?.setData(speakers)
            self.tableView.reloadData()
        }
    }
}

