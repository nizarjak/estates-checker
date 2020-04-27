import Foundation

public enum NotificationsAction {
    case didSendNotification
    case failedToSendNotification(Error)
}
