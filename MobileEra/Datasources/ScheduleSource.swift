import Foundation
import UIKit

class ScheduleSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[safe: section]?.sessionsList?.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let session = data[safe: indexPath.section]?.sessionsList?[safe: indexPath.row] {
            
            if session.isSystemAnnounce == true {
                return
            }
            
            vc?.navigationController?.pushViewController(SessionsDetailsViewController(session: session), animated: true)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SessionTableViewHeader.key) as? SessionTableViewHeader {
            header.set(timeslot: data[safe: section])
            return header
        }
        
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SessionTableViewCell.key) as? SessionTableViewCell {
            cell.set(session: data[safe: indexPath.section]?.sessionsList?[safe: indexPath.row], track: indexPath.row)
            return cell
        }
        
        return UITableViewCell()
    }

    private weak var vc: UIViewController?
    private var data: [Timeslot] = []
    public var allSessions: [Session] = []
    public var schedule: [Day] = []
    public var selectedDay: Int

    public init (_ vc: UIViewController, selectedDay: Int) {
        self.vc = vc
        self.selectedDay = selectedDay
    }

    public func setSelectedDay(_ day: Int) {
        self.selectedDay = day
        
        doFilter()
    }

    public func setData(allSessions: [Session], schedule: [Day]) {
        self.allSessions = allSessions
        self.schedule = schedule
        
        doFilter()
    }

    public func doFilter() {
        data = []
        
        if let day = schedule[safe: selectedDay] {
            for timeslot in day.timeslots {
                data.append(Timeslot(startTime: timeslot.startTime, endTime: timeslot.endTime, sessionsList: timeslot.sessionsList?.filter({isMatchingFilter($0)})))
            }
        }
    }

    private func isMatchingFilter(_ session: Session) -> Bool {
        let showOnlyFavorite = SettingsDataManager.instance.showOnlyFavorite
        if showOnlyFavorite && !session.isFavorite {
            return false
        }
        
        let selectedTags = SettingsDataManager.instance.selectedTags
        if !selectedTags.isEmpty {
            return session.tags?.contains(where: {selectedTags.contains($0)}) ?? false
        }
        
        return true
    }
}
