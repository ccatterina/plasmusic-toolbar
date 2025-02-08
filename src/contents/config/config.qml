import QtQuick 2.0
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-system-windows-behavior"
        source: "config/General.qml"
    }
    ConfigCategory {
        name: i18n("Panel View")
        icon: "preferences-system-windows-effect-screenedge"
        source: "config/Compact.qml"
    }
    ConfigCategory {
        name: i18n("Full View")
        icon: "preferences-system-windows-effect-slidingpopups"
        source: "config/Full.qml"
    }
}
