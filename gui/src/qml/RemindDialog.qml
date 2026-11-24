import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import "controls" as C

import org.streetpea.chiaking

Dialog {
    id: dialog
    property alias text: label.text
    property var remotePlay
    property var callback
    property bool newDialogOpen: false
    property Item restoreFocusItem
    parent: Overlay.overlay
    x: Math.round((root.width - width) / 2)
    y: Math.round((root.height - height) / 2)
    modal: true
    Material.roundedScale: Material.MediumScale
    onOpened: label.forceActiveFocus(Qt.TabFocusReason)
    onAccepted: {
        newDialogOpen = true;
        restoreFocus();
        callback();
    }
    onRejected: {
        if(dialog.remotePlay)
            Chiaki.settings.remotePlayAsk = false;
        else
            Chiaki.settings.addSteamShortcutAsk = false;
    }
    onClosed: {
        if(newDialogOpen)
            return;
        restoreFocus();
        if(!remotePlay && Chiaki.settings.remotePlayAsk)
        {
            if(!Chiaki.settings.psnRefreshToken || !Chiaki.settings.psnAuthToken || !Chiaki.settings.psnAuthTokenExpiry || !Chiaki.settings.psnAccountId)
                root.showRemindDialog(qsTr("PSN 원격 플레이"), qsTr("PSN 계정을 연결하시겠습니까?\n- PS5 자동 등록\n- 포트포워딩 없이 외부 인터넷 연결") + "\n\n" + qsTr("(나중에 설정의 계정 및 구성 메뉴에서 연결할 수 있습니다.)"), true, () => root.showPSNTokenDialog(false));
            else
                Chiaki.settings.remotePlayAsk = false;
        }
    }

    function restoreFocus() {
        if (restoreFocusItem)
            restoreFocusItem.forceActiveFocus(Qt.TabFocusReason);
        label.focus = false;
    }

    Component.onCompleted: {
        header.horizontalAlignment = Text.AlignHCenter;
        // Qt 6.6: Workaround dialog background becoming immediately transparent during close animation
        header.background = null;
    }

    ColumnLayout {
        spacing: 20

        Label {
            id: label
            Keys.onEscapePressed: dialog.reject()
            Keys.onReturnPressed: dialog.accept()
            Keys.onYesPressed: dialog.close()
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter
            spacing: 20

            Button {
                text: qsTr("예")
                Material.background: Material.accent
                flat: true
                leftPadding: 50
                onClicked: dialog.accept()
                Material.roundedScale: Material.SmallScale

                Image {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 12
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: root.controllerButton("cross")
                }
            }

            Button {
                Material.background: Material.accent
                text: qsTr("아니요")
                flat: true
                leftPadding: 50
                onClicked: dialog.reject()
                Material.roundedScale: Material.SmallScale

                Image {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 12
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: root.controllerButton("moon")
                }
            }

            Button {
                Material.background: Material.accent
                text: qsTr("나중에")
                flat: true
                leftPadding: 50
                onClicked: dialog.close()
                Material.roundedScale: Material.SmallScale

                Image {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 12
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: root.controllerButton("pyramid")
                }
            }
        }
    }
}