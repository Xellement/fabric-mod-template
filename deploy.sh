#!/bin/bash

echo "🔨 Building mod..."
./gradlew build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    JAR_FILE=$(ls build/libs/*.jar | grep -v "sources")
    MINECRAFT_MODS="/mnt/c/Users/$USER/AppData/Roaming/.minecraft/mods"
    
    if [ -f "$JAR_FILE" ]; then        
        cp -f "$JAR_FILE" "$MINECRAFT_MODS/"
        echo "✅ Mod copied to $MINECRAFT_MODS"
        echo "📦 File: $(basename $JAR_FILE)"
        echo ""
        echo "🎮 Launch Minecraft Windows with Fabric Loader!"
    else
        echo "❌ JAR not found in build/libs/"
    fi
else
    echo "❌ Build failed!"
    exit 1
fi