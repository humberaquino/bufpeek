import Cocoa
import BufpeekKit

// Data source for the update list
class UpdatesDataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    // The update manager used to get the updates and filter them
    private var updatesManager = UpdatesManager()
    
    // MARK: Manager wrapper methods
    
    func setupDataSource(profiles: [ProfileDAO], updates: [UpdateDAO]) {
        updatesManager.setup(profiles, updates: updates)
    }
    
    func updateUpdateTypes(updateType: [UpdateType]){
        updatesManager.updateTypeFilter = updateType
    }
    
    func updateServiceIds(serviceIds: [String]){
        updatesManager.serviceIdFilter = serviceIds
    }
    
    func currentUpdateProgressValue() -> Double {
        return updatesManager.currentUpdateProgressValue()
    }
    
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return  updatesManager.filteredUpdates.count ?? 0
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let update = updatesManager.filteredUpdates[row]
        if let identifier = tableColumn!.identifier {
            if identifier == "UpdateTableCellView" {
                if let cell = tableView.makeViewWithIdentifier(identifier, owner: self) as? UpdateTableCellView {
                    cell.configureCellUsing(update)
                    return cell
                }
            }
        }
        return nil
    }
}