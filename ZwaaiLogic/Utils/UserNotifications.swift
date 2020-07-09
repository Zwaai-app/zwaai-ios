import UserNotifications

//
// MARK: - Scheduling
//

func scheduleLocalNotification(space: CheckedInSpace, deps: UserNotificationDeps = .default) {
    guard let deadline = space.deadline else { return }

    let content = notificationContent(space: space)
    let trigger = notificationTrigger(deadline: deadline)
    let request = UNNotificationRequest(
        identifier: UUID().uuidString, content: content, trigger: trigger)

    deps.userNotificationCenter.add(request) { error in
        if let error = error {
            print("Failed to add local notification: \(String(describing: error))")
        }
    }
}

func notificationContent(space: CheckedInSpace) -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = NSLocalizedString(
        "Ruimte is automatisch verlaten",
        comment: "auto checkout local notification title")
    let formatString = NSLocalizedString(
        "De ruimte %@ is automatisch verlaten omdat de tijd verstreken is. Als u nog in de ruimte bent, kunt u handmatig opnieuw inchecken.", // swiftlint:disable:this line_length
        comment: "auto checkout local notification body")
    content.body = String.localizedStringWithFormat(formatString, space.name)
    if let sound = notificationSound {
        content.sound = sound
    }
    return content
}

func notificationTrigger(deadline: Date) -> UNNotificationTrigger {
    return UNTimeIntervalNotificationTrigger(
        timeInterval: deadline.timeIntervalSinceNow,
        repeats: false)
}

//
// MARK: - Authorizaiton
//

public func requestLocalNotificationPermission() {
    requestLocalNotificationPermission(deps: .default)
}

func requestLocalNotificationPermission(deps: UserNotificationDeps) {
    copyAudioResourceToSoundsFolder(deps: deps)

    deps.userNotificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
        print("notification auth: \(granted) (error: \(String(describing: error)))")
    }
}

//
// MARK: - Preparation
//

func copyAudioResourceToSoundsFolder(deps: UserNotificationDeps = .default) {
    notificationSound = nil
    guard let libDir = deps.fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first,
        let source = Bundle.zwaaiLogic.url(forResource: notificationSoundName, withExtension: "wav") else {
        return
    }

    let soundsDir = libDir.appendingPathComponent("Sounds")
    let destination = soundsDir.appendingPathComponent(notificationSoundName + ".wav")

    do {
        try deps.fileManager.createDirectory(at: soundsDir, withIntermediateDirectories: true)
        try deps.fileManager.copyItem(at: source, to: destination)
        notificationSound = UNNotificationSound(named: UNNotificationSoundName(notificationSoundName))
    } catch let error {
        print("[error] could not copy notification sound: \(error)")
    }
}

let notificationSoundName = "180048__unfa__sneeze"
var notificationSound: UNNotificationSound?

//
// MARK: - Test support
//

class UserNotificationDeps {
    let fileManager: FileManagerProto
    let userNotificationCenter: UserNotificationCenterProto

    init(fileManager: FileManagerProto = FileManager.default,
         userNotificationCenter: UserNotificationCenterProto = UNUserNotificationCenter.current()) {
        self.fileManager = fileManager
        self.userNotificationCenter = userNotificationCenter
    }

    static var `default` = UserNotificationDeps()
}
