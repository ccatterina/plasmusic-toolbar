import QtQuick 2.5
import QtQuick.Controls 2.5
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons


// from https://develop.kde.org/docs/plasma/widget/examples/#configurable-icon
Button {
    id: configIcon

    property string defaultValue: ''
    property string value: ''

    implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
    implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2

    KQuickAddons.IconDialog {
        id: iconDialog
        onIconNameChanged: configIcon.value = iconName || configIcon.defaultValue
    }

    onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

    PlasmaCore.FrameSvgItem {
        id: previewFrame
        anchors.centerIn: parent
        imagePath: plasmoid.location === PlasmaCore.Types.Vertical || plasmoid.location === PlasmaCore.Types.Horizontal
                 ? "widgets/panel-background" : "widgets/background"
        width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
        height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

        PlasmaCore.IconItem {
            anchors.centerIn: parent
            width: PlasmaCore.Units.iconSizes.large
            height: width
            source: configIcon.value
        }
    }

    Menu {
        id: iconMenu

        // Appear below the button
        y: +parent.height

        MenuItem {
            text: i18ndc("plasma_applet_org.kde.plasma.kickoff", "@item:inmenu Open icon chooser dialog", "Choose...")
            icon.name: "document-open-folder"
            onClicked: iconDialog.open()
        }
        MenuItem {
            text: i18ndc("plasma_applet_org.kde.plasma.kickoff", "@item:inmenu Reset icon to default", "Clear Icon")
            icon.name: "edit-clear"
            onClicked: configIcon.value = configIcon.defaultValue
        }
    }
}
