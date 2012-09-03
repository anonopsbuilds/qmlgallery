/*
 * Copyright (C) 2012 Andrea Bernabei <and.bernabei@gmail.com>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import org.nemomobile.qmlgallery 1.0
import QtMobility.gallery 1.1

Page {
    anchors.fill: parent
    tools: mainTools

    GalleryView {

        id: galleryView

        // Function to handle changing model according to filter and gallery type
        // Image files have date sorting possibility which is achieved only by
        // using gallery model with Image document type.
        // The document type cannot be changed after initialization.
        function filterContent(galleryType, filter) {
            console.debug("Filtering content");
            var sortProperties = gallery.sortProperties;

            if ( galleryType === "Image") {
                gallery = imageGallery;
                if (sortModel.get(0).name !== "Date taken") {
                    sortModel.insert(0, {"name":"Date taken", "ascending":true});
                    // maintain sorting selection
                    if ( pageMenu.sortSelection >= 0 ) {
                        pageMenu.sortSelection++;
                    }
                }
            }else {
                gallery = fileGallery;
                console.debug(sortModel.get(0).name);
                if (sortModel.get(0).name === "Date taken") {
                    sortModel.remove(0);
                    // maintain sorting selection
                    if ( pageMenu.sortSelection > 0 ) {
                        pageMenu.sortSelection--;
                    }
                    else {
                        pageMenu.sortSelection = -1;
                    }
                }
            }
            gallery.sortProperties = sortProperties;
            if ( filter ) {
                gallery.assignNewDestroyCurrent(filter);
            }
        }

        property variant gallery: fileGallery;

        model: gallery;

        // We need two models to support Date taken filtering on images
        // because Document rootType can't be changed after initialization
        GalleryModel {
            id: fileGallery
            rootType: DocumentGallery.File
        }
        GalleryModel {
            id: imageGallery
            rootType: DocumentGallery.Image
        }

        delegate: GalleryDelegate {
            MouseArea {
                anchors.fill: parent
                onClicked: appWindow.pageStack.push(Qt.resolvedUrl("ImagePage.qml"), {visibleIndex: index, galleryModel: gallery} )
            }
        }
    }

    // Two loaders needed to keep modified sort model intact
    Loader {
        id: choiceLoader
        anchors.fill: parent
    }


    ToolBarLayout {
        id: mainTools
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (pageMenu.status === DialogStatus.Closed) ? pageMenu.open() : pageMenu.close()
        }
    }

    Menu {
        id: pageMenu

        // store selections here for restoring destroyed dialog state
        property int filterSelection: 2;
        property int sortSelection: -1;

        MenuLayout {
            MenuItem {
                text: "Slideshow"
                onClicked: appWindow.pageStack.push(Qt.resolvedUrl("ImageSlideshowPage.qml"), {visibleIndex: 0, galleryModel: gallery})
            }
            MenuItem {
                text: "Change type of shown files"
                onClicked: {
                    choiceLoader.source = Qt.resolvedUrl("FileTypeChoiceDialog.qml")
                    choiceLoader.item.open()
                }
            }
            MenuItem {
                text: "Sort content"
                onClicked: {
                    choiceLoader.source = Qt.resolvedUrl("SortDialog.qml")
                    choiceLoader.item.open()
                }
            }
        }
    }

    states: State {
        name: "active"
        when: status === PageStatus.Active || status === PageStatus.Activating

        PropertyChanges {
            target: appWindow.pageStack.toolBar
            opacity: 0.8
        }
    }

    transitions: Transition {
        from: "active"
        reversible: true

        NumberAnimation {
            target: appWindow.pageStack.toolBar
            property: "opacity"
            duration: 250
        }
    }

    // Store the file sort model here to keep modified ascending properties intact
    // after loading another dialog in same loader
    ListModel {
        id: sortModel
        ListElement {name: "Filename"; ascending: true}
        ListElement {name: "Filetype"; ascending: true}
        ListElement {name: "Clear sorting"; ascending: false}// dummy
    }
}
