# 🤝 Contribution

## Development Setup

### 1. Install development dependencies (Debian/Ubuntu):

  The widget is written in QML and does not require the Qt C++ development packages.

  For QML linting:

  ```sh
  sudo apt install qt6-declarative-dev-tools
  ```

### 2. Clone the the repository:

  ```sh
  git clone https://github.com/ccatterina/plasmusic-toolbar
  cd plasmusic-toolbar
  ```
  
---

## Testing Setup

  There are two ways to test the widget. The first is simpler and isolated from your desktop, while the second integrates the development copy into Plasma.
 
### 1. Simple Setup

#### 1.1 Run the widget with `plasmoidviewer`

  ```sh
  plasmoidviewer -a src/ -f horizontal
  ```
  
---
  
### 2. Integrated Setup

#### 2.1 Changes in metadata.json:

  Change the contents of `/src/metadata.json`

  ```sh
  "Id": "plasmusic-toolbar-dev",
  "Name": "PlasMusic Toolbar Dev"
  ```

  > It prevents the development copy conflicting with the released widget.
  > These changes should NOT be commited.

#### 2.2 Install the development widget:

  ```sh
  kpackagetool6 -i ./src --type Plasma/Applet
  ```
  
  This Installation is one-time

#### 2.3 Upgrade the development widget:
  
  ```sh
  kpackagetool6 -u ./src --type Plasma/Applet
  ```

  Upgrading is needed whenever any changes are made.

#### 2.4 Restart Plasmashell to showcase the changes:
  
  ```sh
  systemctl --user restart plasma-plasmashell.service
  ```
  
  Plasmashell needs a restart to reflect the changes made, usually.
