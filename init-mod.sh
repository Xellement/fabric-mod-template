#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display with color
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# Validation function
validate_mod_id() {
    if [[ ! $1 =~ ^[a-z][a-z0-9_]*$ ]]; then
        print_error "Invalid Mod ID. Must start with a lowercase letter and contain only [a-z0-9_]"
        return 1
    fi
    return 0
}

validate_package() {
    if [[ ! $1 =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
        print_error "Invalid package. Expected format: com.author.modname"
        return 1
    fi
    return 0
}

validate_version() {
    if [[ ! $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version. Expected format: 1.21.4"
        return 1
    fi
    return 0
}

# Prerequisites check
check_prerequisites() {
    print_info "Checking prerequisites..."

    if ! command -v java &> /dev/null; then
        print_error "Java is not installed"
        exit 1
    fi

    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        exit 1
    fi

    # Check that we are in a git repo
    if [ ! -d ".git" ]; then
        print_error "This script must be run in a cloned git repo"
        exit 1
    fi

    print_success "Prerequisites OK"
}

# Banner
clear
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════╗
║   Fabric Mod Template Initializer    	║
║             by Xell                   ║
╚═══════════════════════════════════════╝
EOF
echo -e "${NC}"

check_prerequisites

echo ""
print_info "This script will configure your new Fabric mod"
echo ""

# Collect information with validation
while true; do
    read -p "$(echo -e ${BLUE}Mod name${NC} \(e.g.: Super Mod\): )" MOD_NAME
    if [ -n "$MOD_NAME" ]; then
        break
    fi
    print_error "Name cannot be empty"
done

while true; do
    read -p "$(echo -e ${BLUE}Mod ID${NC} \(ex: supermod\): )" MOD_ID
    MOD_ID=$(echo "$MOD_ID" | tr '[:upper:]' '[:lower:]')
    if validate_mod_id "$MOD_ID"; then
        break
    fi
done

while true; do
    read -p "$(echo -e ${BLUE}Author${NC}: )" AUTHOR
    if [ -n "$AUTHOR" ]; then
        break
    fi
    print_error "Author cannot be empty"
done

# Package suggestion based on author and mod ID
SUGGESTED_PACKAGE="com.$(echo $AUTHOR | tr '[:upper:]' '[:lower:]' | tr -d ' ').${MOD_ID}"
while true; do
    read -p "$(echo -e ${BLUE}Package${NC} \(default: $SUGGESTED_PACKAGE\): )" PACKAGE
    PACKAGE=${PACKAGE:-$SUGGESTED_PACKAGE}
    if validate_package "$PACKAGE"; then
        break
    fi
done

# Detecting available versions
print_info "Detecting recent Minecraft versions..."
DEFAULT_MC_VERSION="1.21.4"
while true; do
    read -p "$(echo -e ${BLUE}Minecraft version${NC} \(default: $DEFAULT_MC_VERSION\): )" MC_VERSION
    MC_VERSION=${MC_VERSION:-$DEFAULT_MC_VERSION}
    if validate_version "$MC_VERSION"; then
        break
    fi
done

# Minecraft mods folder configuration
echo ""
print_info "Minecraft mods folder configuration"

# Detect default mods folder based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Check if running in WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
        DEFAULT_MODS_FOLDER="/mnt/c/Users/$USER/AppData/Roaming/.minecraft/mods"
    else
        DEFAULT_MODS_FOLDER="$HOME/.minecraft/mods"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    DEFAULT_MODS_FOLDER="$HOME/Library/Application Support/minecraft/mods"
elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
    DEFAULT_MODS_FOLDER="$APPDATA/.minecraft/mods"
else
    DEFAULT_MODS_FOLDER="$HOME/.minecraft/mods"
fi

read -p "$(echo -e ${BLUE}Minecraft mods folder${NC} \(default: $DEFAULT_MODS_FOLDER\): )" MODS_FOLDER
MODS_FOLDER=${MODS_FOLDER:-$DEFAULT_MODS_FOLDER}

# Advanced options
echo ""
read -p "$(echo -e ${YELLOW}Advanced configuration?${NC} \(y/n, default: n\): )" ADVANCED
ADVANCED=${ADVANCED:-n}

FABRIC_VERSION="0.110.5+1.21.4"
LOADER_VERSION="0.16.9"
YARN_MAPPINGS="1.21.4+build.1"

if [ "$ADVANCED" = "y" ]; then
    read -p "$(echo -e ${BLUE}Fabric API version${NC} \(default: $FABRIC_VERSION\): )" CUSTOM_FABRIC
    FABRIC_VERSION=${CUSTOM_FABRIC:-$FABRIC_VERSION}

    read -p "$(echo -e ${BLUE}Fabric Loader version${NC} \(default: $LOADER_VERSION\): )" CUSTOM_LOADER
    LOADER_VERSION=${CUSTOM_LOADER:-$LOADER_VERSION}

    read -p "$(echo -e ${BLUE}Yarn mappings${NC} \(default: $YARN_MAPPINGS\): )" CUSTOM_YARN
    YARN_MAPPINGS=${CUSTOM_YARN:-$YARN_MAPPINGS}
fi

# Deriving values
MOD_CLASS="${MOD_ID^}Mod"
PACKAGE_PATH=$(echo $PACKAGE | tr '.' '/')
ARCHIVES_NAME=$(echo $MOD_ID | tr '[:upper:]' '[:lower:]')

# Summary display
echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Final Configuration          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BLUE}Name:${NC}            $MOD_NAME"
echo -e "  ${BLUE}ID:${NC}              $MOD_ID"
echo -e "  ${BLUE}Class:${NC}           $MOD_CLASS"
echo -e "  ${BLUE}Package:${NC}         $PACKAGE"
echo -e "  ${BLUE}Author:${NC}          $AUTHOR"
echo -e "  ${BLUE}MC Version:${NC}      $MC_VERSION"
echo -e "  ${BLUE}Fabric API:${NC}      $FABRIC_VERSION"
echo -e "  ${BLUE}Loader:${NC}          $LOADER_VERSION"
echo -e "  ${BLUE}Mods folder:${NC}     $MODS_FOLDER"
echo ""
read -p "$(echo -e ${YELLOW}Confirm and create project?${NC} \(y/n\): )" CONFIRM

if [ "$CONFIRM" != "y" ]; then
    print_error "Cancelled by user"
    exit 1
fi

echo ""
print_info "Configuring project..."

# Backup old content (if reusing)
if [ -d "src/main/java" ] && [ "$(ls -A src/main/java)" ]; then
    print_warning "Removing old source code..."
    rm -rf src/main/java/*
fi

# Creating the structure
print_info "Creating package structure..."
mkdir -p "src/main/java/$PACKAGE_PATH/item"
mkdir -p "src/main/java/$PACKAGE_PATH/block"
mkdir -p "src/main/resources/assets/$MOD_ID/textures/item"
mkdir -p "src/main/resources/assets/$MOD_ID/textures/block"
mkdir -p "src/main/resources/assets/$MOD_ID/lang"
mkdir -p "src/main/resources/data/$MOD_ID/recipes"
mkdir -p "src/main/resources/data/$MOD_ID/loot_tables"

# Configuring gradle.properties
print_info "Configuring gradle.properties..."
cat > gradle.properties << EOF
# Mod Properties
archives_base_name = $ARCHIVES_NAME
maven_group = $PACKAGE
mod_version = 1.0.0

# Minecraft & Fabric
minecraft_version=$MC_VERSION
yarn_mappings=$YARN_MAPPINGS
loader_version=$LOADER_VERSION
fabric_version=$FABRIC_VERSION

# Java
org.gradle.jvmargs=-Xmx2G
org.gradle.daemon=true
EOF

# Configuring fabric.mod.json
print_info "Configuring fabric.mod.json..."
cat > src/main/resources/fabric.mod.json << EOF
{
  "schemaVersion": 1,
  "id": "$MOD_ID",
  "version": "\${version}",
  "name": "$MOD_NAME",
  "description": "A Fabric mod created with fabric-mod-template",
  "authors": ["$AUTHOR"],
  "contact": {
    "homepage": "https://github.com/$AUTHOR/$MOD_ID",
    "sources": "https://github.com/$AUTHOR/$MOD_ID"
  },
  "license": "MIT",
  "icon": "assets/$MOD_ID/icon.png",
  "environment": "*",
  "entrypoints": {
    "main": [
      "$PACKAGE.$MOD_CLASS"
    ]
  },
  "mixins": [
    "$MOD_ID.mixins.json"
  ],
  "depends": {
    "fabricloader": ">=0.16.0",
    "minecraft": "~$MC_VERSION",
    "java": ">=21",
    "fabric-api": "*"
  },
  "suggests": {
    "another-mod": "*"
  }
}
EOF

# Creating mixin config file
print_info "Configuring mixins..."
cat > "src/main/resources/$MOD_ID.mixins.json" << EOF
{
  "required": true,
  "package": "$PACKAGE.mixin",
  "compatibilityLevel": "JAVA_21",
  "mixins": [],
  "injectors": {
    "defaultRequire": 1
  }
}
EOF

# Creating the main class
print_info "Creating main class..."
cat > "src/main/java/$PACKAGE_PATH/${MOD_CLASS}.java" << EOF
package $PACKAGE;

import ${PACKAGE}.item.ModItems;
import net.fabricmc.api.ModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ${MOD_CLASS} implements ModInitializer {
    public static final String MOD_ID = "$MOD_ID";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        LOGGER.info("Initializing {} by $AUTHOR", MOD_ID);
        
        ModItems.registerModItems();
    }
}
EOF

# Creating ModItems
print_info "Creating ModItems..."
cat > "src/main/java/$PACKAGE_PATH/item/ModItems.java" << EOF
package ${PACKAGE}.item;

import ${PACKAGE}.${MOD_CLASS};
import net.fabricmc.fabric.api.itemgroup.v1.ItemGroupEvents;
import net.minecraft.item.Item;
import net.minecraft.item.ItemGroups;
import net.minecraft.registry.Registries;
import net.minecraft.registry.Registry;
import net.minecraft.util.Identifier;

public class ModItems {

    // Example item
    // public static final Item EXAMPLE_ITEM = registerItem("example_item",
    //     new Item(new Item.Settings()));

    private static Item registerItem(String name, Item item) {
        return Registry.register(Registries.ITEM,
            Identifier.of(${MOD_CLASS}.MOD_ID, name), item);
    }

    public static void registerModItems() {
        ${MOD_CLASS}.LOGGER.info("Registering items for {}", ${MOD_CLASS}.MOD_ID);

        // Add your items to the creative tab
        // ItemGroupEvents.modifyEntriesEvent(ItemGroups.INGREDIENTS)
        //     .register(entries -> entries.add(EXAMPLE_ITEM));
    }
}
EOF

# Creating default language file
print_info "Creating language file..."
cat > "src/main/resources/assets/$MOD_ID/lang/en_us.json" << EOF
{
  "itemGroup.$MOD_ID": "$MOD_NAME"
}
EOF

# Creating deploy.sh with custom mods folder
print_info "Creating deployment script..."
cat > deploy.sh << 'DEPLOY_EOF'
#!/bin/bash

echo "🔨 Building mod..."
./gradlew build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"

    JAR_FILE=$(ls build/libs/*.jar 2>/dev/null | grep -v "sources" | head -1)
DEPLOY_EOF

# Add the mods folder path (with proper escaping)
echo "    MINECRAFT_MODS=\"$MODS_FOLDER\"" >> deploy.sh

cat >> deploy.sh << 'DEPLOY_EOF'

    if [ -f "$JAR_FILE" ]; then
        # Create mods folder if it doesn't exist
        mkdir -p "$MINECRAFT_MODS"
        cp -f "$JAR_FILE" "$MINECRAFT_MODS/"
        echo "✅ Mod copied to $MINECRAFT_MODS"
        echo "📦 File: $(basename $JAR_FILE)"
        echo ""
        echo "🎮 Launch Minecraft with Fabric Loader!"
    else
        echo "❌ JAR not found in build/libs/"
    fi
else
    echo "❌ Build failed!"
    exit 1
fi
DEPLOY_EOF

chmod +x deploy.sh

# Git configuration
print_info "Configuring Git..."
git add .
git commit -m "Initialize $MOD_NAME project

- Mod ID: $MOD_ID
- Author: $AUTHOR
- Package: $PACKAGE
- Minecraft: $MC_VERSION" --allow-empty

# Cleanup of the script itself
print_info "Cleaning up..."
rm -f init-mod.sh

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Project created successfully!     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
print_info "Next steps:"
echo ""
echo "  1. ${BLUE}./gradlew build${NC}          - Build your mod"
echo "  2. ${BLUE}./deploy.sh${NC}              - Deploy to Minecraft"
echo "  3. ${BLUE}Launch Minecraft${NC}         - Test your mod"
echo ""
print_info "Created structure:"
echo "  📁 src/main/java/$PACKAGE_PATH/"
echo "     ├── ${MOD_CLASS}.java"
echo "     └── item/ModItems.java"
echo ""
print_success "Happy modding! 🎮"
echo ""