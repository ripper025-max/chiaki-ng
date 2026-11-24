import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import org.streetpea.chiaking

import "controls" as C

DialogView {
    property bool ps5: true
    property alias host: hostField.text
    title: qsTr("PS5 / PS4 등록")
    buttonText: qsTr("등록")
    buttonEnabled: hostField.text.trim() && pin.acceptableInput && cpin.acceptableInput && (!onlineId.visible || onlineId.text.trim()) && (ps4_7.checked || accountId.text.trim())
    StackView.onActivated: {
        if(!accountId.text.trim() && Chiaki.settings.psnAccountId)
            accountId.text = Chiaki.settings.psnAccountId
    }
    onAccepted: {
        let psnId = onlineId.visible ? onlineId.text.trim() : accountId.text.trim();
        let registerOk = Chiaki.registerHost(hostField.text.trim(), psnId, pin.text.trim(), cpin.text.trim(), hostField.text.trim() == "255.255.255.255", consoleButtons.checkedButton.target, function(msg, ok, done) {
            if (!done)
                logArea.text += msg + "\n";
            else
                logDialog.standardButtons = Dialog.Close;
        });
        if (registerOk) {
            logArea.text = "";
            logDialog.open();
        }
    }

    Item {
        GridLayout {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 20
            }
            columns: 2
            rowSpacing: 10
            columnSpacing: 20

            Label {
                Layout.alignment: Qt.AlignRight
                text: qsTr("콘솔 IP 주소:")
            }

            C.TextField {
                id: hostField
                echoMode: Chiaki.settings.streamerMode ? TextInput.Password : TextInput.Normal
                Layout.preferredWidth: 400
                firstInFocusChain: true
            }

            Label {
                Layout.alignment: Qt.AlignRight
                text: qsTr("PSN 닉네임:")
                visible: onlineId.visible
            }

            C.TextField {
                id: onlineId
                echoMode: Chiaki.settings.streamerMode ? TextInput.Password : TextInput.Normal
                visible: ps4_7.checked
                placeholderText: qsTr("PSN 닉네임 (대소문자 구분)")
                Layout.preferredWidth: 400
            }

            Label {
                Layout.alignment: Qt.AlignRight
                text: qsTr("PSN 계정 ID:")
                visible: !ps4_7.checked
            }

            RowLayout {
                visible: !ps4_7.checked
                Layout.preferredWidth: 400
                spacing: 10

                C.TextField {
                    id: accountId
                    Layout.fillWidth: true
                    Layout.minimumWidth: 180
                    echoMode: Chiaki.settings.streamerMode ? TextInput.Password : TextInput.Normal
                    placeholderText: qsTr("계정 ID")
                    KeyNavigation.up: hostField
                    KeyNavigation.right: loginButton
                    KeyNavigation.down: pin
                }

                C.Button {
                    id: loginButton
                    Layout.preferredWidth: 150
                    Layout.minimumWidth: 150
                    text: qsTr("PSN 로그인")
                    visible: true
                    enabled: true
                    onClicked: stack.push(psnLoginDialogComponent, {
                        login: true,
                        callback: function(id) {
                            accountId.text = id;
                            pin.forceActiveFocus(Qt.TabFocusReason);
                        }
                    })
                    Material.roundedScale: Material.SmallScale
                    KeyNavigation.left: accountId
                    KeyNavigation.down: pin
                }
            }

            Item { Layout.preferredWidth: 1 }
            Label {
                Layout.preferredWidth: 400
                wrapMode: Text.WordWrap
                visible: !ps4_7.checked
                text: qsTr("PSN 로그인 버튼을 눌러 소니 계정으로 로그인하세요.\n계정 ID가 자동으로 입력됩니다.")
                opacity: 0.85
            }

            Label {
                Layout.alignment: Qt.AlignRight
                text: qsTr("PS5 기기 연결 코드 (8자리):")
            }

            C.TextField {
                id: pin
                validator: RegularExpressionValidator { regularExpression: /[0-9]{8}/ }
                Layout.preferredWidth: 400
                echoMode: Chiaki.settings.streamerMode ? TextInput.Password : TextInput.Normal
                KeyNavigation.priority: {
                    if(readOnly)
                        KeyNavigation.BeforeItem
                    else
                        KeyNavigation.AfterItem
                }
                KeyNavigation.up: accountId
            }

            Label {
                Layout.alignment: Qt.AlignRight
                text: qsTr("콘솔 로그인 PIN (선택)")
            }

            C.TextField {
                id: cpin
                echoMode: Chiaki.settings.streamerMode ? TextInput.Password : TextInput.Normal
                validator: RegularExpressionValidator { regularExpression: /^$|[0-9]{4}/ }
                Layout.preferredWidth: 400
            }

            Label {
                Layout.alignment: Qt.AlignRight
                text: qsTr("콘솔 종류:")
            }

            ColumnLayout {
                spacing: 0

                C.RadioButton {
                    id: ps4_7
                    property int target: 800
                    text: qsTr("PS4 Firmware < 7.0")
                }

                C.RadioButton {
                    id: ps4_75
                    property int target: 900
                    text: qsTr("PS4 Firmware >= 7.0, < 8.0")
                }

                C.RadioButton {
                    id: ps4_8
                    property int target: 1000
                    text: qsTr("PS4 Firmware >= 8.0")
                    checked: !ps5
                }

                C.RadioButton {
                    id: ps5_0
                    property int target: 1000100
                    lastInFocusChain: true
                    text: qsTr("PS5")
                    checked: ps5
                }
            }
        }

        ButtonGroup {
            id: consoleButtons
            buttons: [ps4_7, ps4_75, ps4_8, ps5_0]
        }

        Item {
            Dialog {
                id: logDialog
                parent: Overlay.overlay
                x: Math.round((root.width - width) / 2)
                y: Math.round((root.height - height) / 2)
                title: qsTr("PS5 / PS4 등록")
                modal: true
                closePolicy: Popup.NoAutoClose
                standardButtons: Dialog.Cancel
                Material.roundedScale: Material.MediumScale
                onOpened: logArea.forceActiveFocus(Qt.TabFocusReason)
                onClosed: stack.pop();

                Flickable {
                    id: logFlick
                    implicitWidth: 600
                    implicitHeight: 400
                    clip: true
                    contentWidth: logArea.contentWidth
                    contentHeight: logArea.contentHeight
                    flickableDirection: Flickable.AutoFlickIfNeeded
                    ScrollBar.vertical: ScrollBar {
                        id: logScrollbar
                        policy: ScrollBar.AlwaysOn
                        visible: logFlick.contentHeight > logFlick.implicitHeight
                    }

                    Label {
                        id: logArea
                        width: logFlick.width
                        wrapMode: TextEdit.Wrap
                        Keys.onReturnPressed: if (logDialog.standardButtons == Dialog.Close) logDialog.close()
                        Keys.onEscapePressed: logDialog.close()
                        Keys.onPressed: (event) => {
                            switch (event.key) {
                            case Qt.Key_Up:
                                if(logScrollbar.position > 0.001)
                                    logFlick.flick(0, 500);
                                event.accepted = true;
                                break;
                            case Qt.Key_Down:
                                if(logScrollbar.position < 1.0 - logScrollbar.size - 0.001)
                                    logFlick.flick(0, -500);
                                event.accepted = true;
                                break;
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: psnLoginDialogComponent
            PSNLoginDialog { }
        }
    }
}
