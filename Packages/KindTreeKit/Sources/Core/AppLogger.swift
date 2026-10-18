import os

public enum AppLogger {
    private static let subsystem = "com.kindtree.swap"

    public static let network = Logger(subsystem: subsystem, category: "network")
    public static let services = Logger(subsystem: subsystem, category: "services")
    public static let ui = Logger(subsystem: subsystem, category: "ui")
}
