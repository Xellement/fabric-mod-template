# Fabric Mod Template

A clean and automated template for creating Minecraft mods with Fabric.

## Quick Start

```bash
# 1. Clone the template
git clone https://github.com/Xellement/fabric-mod-template.git my-new-mod
cd my-new-mod

# 2. Run the initialization script
chmod +x init-mod.sh
./init-mod.sh

# 3. Build and deploy
./gradlew build
./deploy.sh
```

## Prerequisites

- **Java 21+** - Required for Minecraft 1.21+
- **Git** - For version control
- **Minecraft** with Fabric Loader installed

## Features

- Automated setup with input validation
- Complete project structure ready to use
- One-click deployment script to Minecraft mods folder
- **Cross-platform mods folder auto-detection** (WSL, Linux, macOS, Windows)
- Custom mods folder support (MultiMC, Prism Launcher, etc.)
- Optimized Gradle configuration
- Mixin support pre-configured
- Language file template included

## What the init script does

The `init-mod.sh` script will interactively ask you for:

| Field | Description | Example |
|-------|-------------|---------|
| Mod name | Display name of your mod | `Super Mod` |
| Mod ID | Unique identifier (lowercase) | `supermod` |
| Author | Your name or username | `Xell` |
| Package | Java package name | `com.xell.supermod` |
| Minecraft version | Target MC version | `1.21.4` |
| Mods folder | Path to Minecraft mods folder | Auto-detected |

Advanced options (optional):
- Fabric API version
- Fabric Loader version
- Yarn mappings version

### Mods folder auto-detection

The script automatically detects the correct mods folder based on your OS:

| Platform | Default path |
|----------|--------------|
| WSL (Windows Subsystem for Linux) | `/mnt/c/Users/$USER/AppData/Roaming/.minecraft/mods` |
| Linux | `~/.minecraft/mods` |
| macOS | `~/Library/Application Support/minecraft/mods` |
| Windows (Git Bash/Cygwin) | `$APPDATA/.minecraft/mods` |

You can override this with any custom path (e.g., for MultiMC, Prism Launcher, or a different Minecraft instance).

## Generated Project Structure

```
my-mod/
├── build.gradle
├── gradle.properties
├── settings.gradle
├── deploy.sh
├── src/
│   └── main/
│       ├── java/com/author/mymod/
│       │   ├── MymodMod.java          # Main mod class
│       │   └── item/
│       │       └── ModItems.java      # Item registration
│       └── resources/
│           ├── fabric.mod.json        # Mod metadata
│           ├── mymod.mixins.json      # Mixin configuration
│           └── assets/mymod/
│               ├── lang/
│               │   └── en_us.json     # Translations
│               └── textures/
│                   ├── item/          # Item textures
│                   └── block/         # Block textures
└── data/mymod/
    ├── recipes/                       # Custom recipes
    └── loot_tables/                   # Loot tables
```

## Deployment

The `deploy.sh` script builds your mod and copies it to the Minecraft mods folder you specified during initialization.

Features:
- Automatically creates the mods folder if it doesn't exist
- Overwrites previous versions of your mod
- Shows the deployed file name

Make sure Minecraft is closed before deploying, then launch with Fabric Loader.

To change the deployment path after initialization, edit the `MINECRAFT_MODS` variable in `deploy.sh`.

## Adding Items

Edit `src/main/java/.../item/ModItems.java`:

```java
public static final Item MY_ITEM = registerItem("my_item",
    new Item(new Item.Settings()));

public static void registerModItems() {
    // Add to creative tab
    ItemGroupEvents.modifyEntriesEvent(ItemGroups.INGREDIENTS)
        .register(entries -> entries.add(MY_ITEM));
}
```

Don't forget to add the texture at `assets/modid/textures/item/my_item.png` and the translation in `lang/en_us.json`.

## Useful Commands

| Command | Description |
|---------|-------------|
| `./gradlew build` | Build the mod JAR |
| `./gradlew runClient` | Run Minecraft with the mod |
| `./deploy.sh` | Build and copy to mods folder |
| `./gradlew clean` | Clean build files |

## Resources

- [Fabric Wiki](https://fabricmc.net/wiki/)
- [Fabric API Documentation](https://maven.fabricmc.net/docs/fabric-api-latest/)
- [Minecraft Wiki - Data Packs](https://minecraft.wiki/w/Data_pack)

## License

MIT

## Author

Xell - [@Xellement](https://github.com/Xellement)