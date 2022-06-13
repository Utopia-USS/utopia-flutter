# utopia_widgets

Miscellaneous, basic widgets.

## Highlights

### FormLayout and TopBottomLayout

Two basic layouts designed for "long" (content probably won't fit on screen, and we don't want to scroll all the way to
the bottom to press the submit button) and "short" (content can be smaller than screen, but in case it's not - scroll)
screens.

### CrossFadeIndexedStack

Like `IndexedStack`, but pages fade through during transitions and can be lazy-initialized. Designed for usage as
content of screen controlled by `BottomNavigationBar`. 
