import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQml.Models 2.2

Item {
    width: 1280
    height: 480
    anchors.fill: parent
    RowLayout {
        anchors.fill: parent
        // 左側のリスト
        ListView {
            id: leftList
            Layout.fillHeight: true
            Layout.preferredWidth: 200
            focus: true
            model: dataModel
            delegate: leftDelegate
            highlight: highlight
            highlightMoveDuration: 200
            Keys.onUpPressed: decrementCurrentIndex()
            Keys.onDownPressed: incrementCurrentIndex()
            Keys.onRightPressed: rightList.focus = true
            keyNavigationWraps: true
        }
        // 右側のリスト
        ListView {
            id: rightList
            Layout.fillHeight: true
            Layout.preferredWidth: 400
            // [2] modelにDelegateModelを使う
            model: DelegateModel {
                rootIndex: leftList.model.index(leftList.currentIndex, 0) // [2] rootIndex指定
                model: leftList.model
                delegate: rightDelegate // [2] DelegateModel.delegate でデリゲート指定
                onRootIndexChanged: rightList.positionViewAtBeginning()
            }
            // delegate: rightDelegate // [3] 効かない
            highlight: highlight
            highlightMoveDuration: 200
            Keys.onUpPressed: decrementCurrentIndex()
            Keys.onDownPressed: incrementCurrentIndex()
            Keys.onLeftPressed: leftList.focus = true
            keyNavigationWraps: true
        }
    }

    Component {
        id: highlight
        Rectangle {
            color: Qt.rgba(0,0,1,ListView.view.focus ? 0.5 : 0.2)
            z: 100
        }
    }

    Component {
        id: leftDelegate
        Text {
            text: display // Qt::DisplayRole
            height: 32
            font.pixelSize: 24
            width: ListView.view.width
            verticalAlignment: Text.AlignVCenter
        }
    }

    Component {
        id: rightDelegate
        RowLayout {
            height: 32
            width: ListView.view.width
            property string name: display // Qt::DisplayRole
            property color iconColor: decoration // Qt::DecorationRole
            Rectangle {
                Layout.maximumWidth: 24
                Layout.maximumHeight: 24
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                color: Qt.lighter(parent.iconColor)
                border.color: Qt.black
                border.width: 1
            }
            Text {
                text: parent.name
                Layout.fillWidth: true
                Layout.fillHeight: true
                font.pixelSize: 24
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
