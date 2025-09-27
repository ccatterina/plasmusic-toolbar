import QtQuick

Image {
    id: imageWithPlaceholder

    property string placeholderSource
    property string imageSource
    property bool imageLoadFailed: false

    onImageSourceChanged: {
        // Reset the flag when the image URL changes
        imageLoadFailed = false
    }

    onStatusChanged: {
        if (status === Image.Error) {
            imageLoadFailed = true;
        }
    }

    source: imageLoadFailed || !imageSource ? placeholderSource : imageSource
}