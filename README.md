# HUD
an iOS HUD implemented in Swift as an iOS8 Framework

![Loading](https://raw.githubusercontent.com/Hello24/HUD/master/Docs/HUD_loading.png)


## How to install

 1. Download the zip archive of this project or add it as a git submodule. In Terminal, navigate to your project folder and type:

```
git submodule add git@github.com:Hello24/HUD.git Modules/HUD
```

 2. Add the framework to your project by dragging HUD.xcodeproj into your project:

![Install](https://raw.githubusercontent.com/Hello24/HUD/master/Docs/HUD_install1.png)


 3. Amend your target build phases to link to the HUD framework.

![Install](https://raw.githubusercontent.com/Hello24/HUD/master/Docs/HUD_install2.png)


 4. Import the module where required:

```
import HUD
```


## Usage

```
H24HUD.showLoading("Loading...")

H24HUD.showSuccess("Projects loaded successfully.")

H24HUD.showFailure("Something went wrong. Please try again!")

H24HUD.hide()
```


