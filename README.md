# pfUI More Datatexts

An external module for pfUI that adds more datatexts for your panels! There will be more datatexts coming in future versions.

## Features

Here is an exhaustive list of all the extra datatexts added by this addon. You can add these to any compatible panels in pfUI!  
Some datatexts have extra settings once enabled.  
Some datatexts require extra addons to be enabled.  

| Datatext Name | Description | Extra Settings | Addon Requirement |
| ------------- | ----------- | :------------: | :---------------: |
| Reputation | Tracks any faction reputation changes or your watched faction's reputation. | 1 | — |
| WIM | Keep track of conversations and be alerted to newly received whispers. | — | [WIM](https://github.com/refaim/WIM) |

## Screenshots

## Installation

This addon requires [pfUI](https://github.com/shagu/pfUI) or one of its maintained forks, like [me0wg4ming's fork](https://github.com/me0wg4ming/pfUI). Make sure to download and install one of them first.

### Turtle WoW Launcher (**Recommended**)

1. Open the Turtle WoW Launcher and navigate to the `ADDONS` tab at the top.
2. Press the `Add new addon` button and paste the following URL into the field: `https://github.com/Arthur-Helias/pfUI-MoreDatatexts.git`.
3. Enable the addon from the addons menu on the character selection screen.

### Manual installation

1. Download the [latest version](https://github.com/Arthur-Helias/pfUI-MoreDatatexts/archive/refs/heads/master.zip) of the addon.
2. Extract the archive.
3. Rename the folder from "pfUI-moredatatexts-master" to "pfUI-moredatatexts".
4. Copy the renamed folder into `WoW-Directory\Interface\AddOns`.
5. Enable the addon from the addons menu on the character selection screen.

## Known Issues

None so far. Please report any issues you encounter through the `Issues` tab on this repository. Feel free to make a PR if you wish to contribute to this addon!

## Compatibility

This addon was designed and tested for TurtleWoW. It should be compatible with any 1.12 client that does not add or modify zones.  
This addon is compatible with [the original pfUI by Shagu](https://github.com/shagu/pfUI), but also its actively maintained forks such as [me0wg4ming's](https://github.com/me0wg4ming/pfUI).  

## Addon Recommendations

Here are a few other addons that improve pfUI or other parts of the game and do not conflict with this addon:

- [pfUI-LocationPlus](https://github.com/Arthur-Helias/pfUI-LocationPlus) - Another module for pfUI that adds two extra panels compatible with this addon.
- [pfUI-addonskinner](https://github.com/jrc13245/pfUI-addonskinner) - Another module for pfUI that skins other addons to match the style of pfUI.
- [ZonesLevel](https://github.com/Arthur-Helias/ZonesLevel) - Adds zones level range to your world map.

## Contributing

Feel free to take inspiration from the existing datatexts to make your own. Simply make a new .lua file in the datatexts folder, register it, and don't forget to add it to the .toc file.  
Make a PR with your contributions and I'll make sure to merge it into the main addon!  
You can also suggest datatexts ideas through the `Issues` tab on this repository and I might implement them.

## Credits

[Walter Bennet](https://github.com/Arthur-Helias) - Addon creation  
[Shagu](https://github.com/shagu) - pfUI  
[dein0s](https://github.com/Arthur-Helias) - Code inspiration from pfUI-addonskinner  
[Refaim](https://github.com/refaim) - Maintaining the current version of WIM  
