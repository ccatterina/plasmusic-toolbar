import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Dialogs
import org.kde.plasma.private.mpris as Mpris

Dialog {
    title: "Choose MPRIS preferred source"
    modal: true
    property var selectedSource: null
    property var mpris2Model: Mpris.Mpris2Model {}
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    standardButtons: Dialog.Ok | Dialog.Cancel
    onAccepted: {
        selectedSource = mprisSourceComboBox.currentValue
    }

    contentItem: Kirigami.FormLayout {
        Layout.preferredHeight: implicitHeight
        Layout.minimumHeight: implicitHeight
        ListModel {
            id: sources
            function reload() {
                sources.clear()
                sources.append({desktopEntry: "any", identity: "Choose automatically"})

                const CONTAINER_ROLE = Qt.UserRole + 1
                for (var i = 1; i < mpris2Model.rowCount(); i++) {
                    const player = mpris2Model.data(mpris2Model.index(i, 0), CONTAINER_ROLE)
                    sources.append({desktopEntry: player.desktopEntry, identity: player.identity})
                }
            }
            Component.onCompleted: reload()
        }

        RowLayout {
            id: sourceInput
            // Layout.preferredHeight: b.implicitHeight

            ComboBox {
                id: mprisSourceComboBox
                model: sources
                textRole: "identity"
                currentIndex: 0
            }

            Button {
                id: b
                icon.name: 'refreshstructure'
                onClicked: sources.reload()
            }
        }
    }
}