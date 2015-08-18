import Cocoa
import BufpeekKit

// Cell view for a single update
class UpdateTableCellView: NSTableCellView {

    @IBOutlet var textTextField: NSTextField!
    @IBOutlet var scheduledAtTextField: NSTextField!
    @IBOutlet var viaTextField: NSTextField!
    @IBOutlet var typeTextField: NSTextField!
    @IBOutlet var serviceImageView: NSImageView!
    
    func configureCellUsing(update: UpdateDAO) {
        
        if let type = update.type {
            if type == SocialService.Twitter.rawValue {
                textTextField.stringValue = update.retweetText!
                typeTextField.stringValue = "\(type) from @\(update.retweetUsername!)"
            } else {
                textTextField.stringValue = update.text ?? "!!Error: No text!!"
                typeTextField.stringValue = type
            }
        } else {
            typeTextField.stringValue = ""
            textTextField.stringValue = update.text ?? "!!Error: No text!!"
        }
        
        viaTextField.stringValue = update.via!
        scheduledAtTextField.stringValue = "--"
        
        if let udpateType = update.updateType {
            if udpateType == UpdateType.Pending {
                if let scheduledAt = update.scheduledAt {
                    scheduledAtTextField.stringValue = scheduledAt.formattedAsTime
                } else {
                    if let dueAt = update.dueAt {
                        scheduledAtTextField.stringValue = dueAt.formattedAsTime
                    }
                }
            } else {
                if let sentAt = update.sentAt {
                    scheduledAtTextField.stringValue = sentAt.formattedAsTime
                }
            }
        }
        
        if let profileService = update.profileService {
            serviceImageView?.image = NSImage(named: profileService)
        }
    }
    
    
}
