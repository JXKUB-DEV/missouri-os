var panel = new Panel;
panel.location = "bottom";
panel.height = 44;

// Missouri OS application launcher
var launcher = panel.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "/usr/share/pixmaps/missouri-os-logo.png");

// Task manager
panel.addWidget("org.kde.plasma.icontasks");

// System tray
panel.addWidget("org.kde.plasma.systemtray");

// Digital clock
panel.addWidget("org.kde.plasma.digitalclock");
