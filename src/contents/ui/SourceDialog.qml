import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Dialogs
import org.kde.plasma.private.mpris as Mpris

Dialog {
    title: "Choose MPRIS source"
    modal: true
    signal sourceSelected(identity: string)
    property var mpris2Model: Mpris.Mpris2Model {}
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    standardButtons: Dialog.Ok | Dialog.Cancel
    onAccepted: {
        if (mprisSourceComboBox.currentValue?.identity) {
            sourceSelected(mprisSourceComboBox.currentValue.identity)
        }
    }

    contentItem: Kirigami.FormLayout {
        Layout.preferredHeight: implicitHeight
        Layout.minimumHeight: implicitHeight
        ListModel {
            id: sources
            function reload() {
                sources.clear()

                const CONTAINER_ROLE = Qt.UserRole + 1
                for (var i = 1; i < mpris2Model.rowCount(); i++) {
                    const player = mpris2Model.data(mpris2Model.index(i, 0), CONTAINER_ROLE)
                    sources.append({desktopEntry: player.desktopEntry, identity: player.identity})
                }
            }
            Component.onCompleted: reload()
        }

        ColumnLayout {
            Label {
                text: i18n("Currently running players:")
            }
            RowLayout {
                id: sourceInput

                ComboBox {
                    id: mprisSourceComboBox
                    model: sources
                    textRole: "identity"
                    currentIndex: 0
                }

                Button {
                    icon.name: 'refreshstructure'
                    onClicked: sources.reload()
                }

                Kirigami.ContextualHelpButton {
                    toolTipText: i18n(
                        "In the dropdown you can choose between all the players that are currently running, " +
                        "if you can't find the one you want, open the player application and reload the list " +
                        "with reload button."
                    )
                }
            }
        }
    }
}
