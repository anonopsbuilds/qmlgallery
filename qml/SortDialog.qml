import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.gallery 1.1

SelectionDialog {

    titleText: "Sort by"
    model: sortModel


    // Handle item selection here instead in selectedIndexChanged to react on same selection
    function itemSelected(selection) {
        // Check if we need to change from asc to desc or vice versa
        if ( selection === selectedIndex ) {
            model.setProperty(selection, "ascending", !model.get(selection).ascending);
        }
        selectedIndex = selection;
        switch(model.get(selection).name) {
        case "Date taken":
            if ( model.get(selection).ascending ) {
                galleryView.gallery.sortProperties = ["dateTaken"];
            }
            else {
                galleryView.gallery.sortProperties = ["-dateTaken"];
            }
            break;
        case "Filename":
            if ( model.get(selection).ascending ) {
                galleryView.gallery.sortProperties = ["fileName"];
            }
            else {
                galleryView.gallery.sortProperties = ["-fileName"];
            }
            break;
        case "Filetype":
            if ( model.get(selection).ascending ) {
                galleryView.gallery.sortProperties = ["mimeType"];
            }
            else {
                galleryView.gallery.sortProperties = ["-mimeType"];
            }
            break;
        case "Clear sorting":
            selectedIndex = -1;
            galleryView.gallery.sortProperties = [""];
            break;
        }
        pageMenu.sortSelection = selectedIndex;
    }

    selectedIndex: pageMenu.sortSelection;

    // Delegate modified from default meego SelectionDialog delegate
    delegate: Component {
        id: defaultDelegate

        Item {
            id: delegateItem
            property bool selected: index === selectedIndex;

            height: root.platformStyle.itemHeight
            anchors.left: parent.left
            anchors.right: parent.right


            MouseArea {
                id: delegateMouseArea
                anchors.fill: parent;
                onPressed: {
                    itemSelected(index);
                }
                onClicked:  accept();
            }

            Rectangle {
                id: backgroundRect
                anchors.fill: parent
                color: delegateItem.selected ? root.platformStyle.itemSelectedBackgroundColor : root.platformStyle.itemBackgroundColor
            }

            BorderImage {
                id: background
                anchors.fill: parent
                source: delegateMouseArea.pressed ? root.platformStyle.itemPressedBackground :
                        delegateItem.selected ? root.platformStyle.itemSelectedBackground :
                        root.platformStyle.itemBackground
            }

            Text {
                id: itemText
                elide: Text.ElideRight
                color: delegateItem.selected ? root.platformStyle.itemSelectedTextColor : root.platformStyle.itemTextColor
                anchors.verticalCenter: delegateItem.verticalCenter
                anchors.left: parent.left
                anchors.right: directionIcon.right
                anchors.leftMargin: root.platformStyle.itemLeftMargin
                anchors.rightMargin: root.platformStyle.itemRightMargin
                text: name
                font: root.platformStyle.itemFont
            }
            Image {
                id: directionIcon
                // If the item is selected, show sort direction
                source: selected ? (ascending ? "qrc:/images/up_arrow.png" : "qrc:/images/down_arrow.png") : ""
                anchors.right: parent.right
                height: parent.height / 2
                width: parent.height / 2
                anchors.verticalCenter: parent.verticalCenter
                smooth: true
            }
        }
    }
}
