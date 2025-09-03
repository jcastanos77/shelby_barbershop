#!/bin/bash
# Exit si hay error
set -e

echo "📦 Instalando Flutter $FLUTTER_VERSION..."

# Si existe carpeta flutter de builds anteriores, eliminarla
if [ -d "flutter" ]; then
  rm -rf flutter
fi

# Descargar Flutter SDK
git clone https://github.com/flutter/flutter.git --depth 1 -b stable

# Agregar Flutter al PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# Verificar instalación
flutter doctor -v

# Build de Flutter Web
echo "🚀 Generando build de Flutter Web..."
flutter build web --release

echo "✅ Build completado en build/web"
