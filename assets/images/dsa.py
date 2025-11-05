#!/usr/bin/env python3
import sys
from pathlib import Path
from PIL import Image
import argparse

# Mapa de archivos de salida -> tamaño (px)
SIZES = {
    # Android mipmap
    "android/mipmap-mdpi/ic_launcher.png": 48,
    "android/mipmap-hdpi/ic_launcher.png": 72,
    "android/mipmap-xhdpi/ic_launcher.png": 96,
    "android/mipmap-xxhdpi/ic_launcher.png": 144,
    "android/mipmap-xxxhdpi/ic_launcher.png": 192,
    # Play Store / icono grande
    "android/playstore-icon.png": 512,

    # iOS AppIcon (ejemplos)
    "ios/AppIcon-20.png": 20,
    "ios/AppIcon-29.png": 29,
    "ios/AppIcon-40.png": 40,
    "ios/AppIcon-60.png": 60,
    "ios/AppIcon-76.png": 76,
    "ios/AppIcon-83.5.png": 83,
    "ios/AppIcon-1024.png": 1024,
}

def find_input_path(p: str) -> Path | None:
    p = Path(p)
    if p.exists():
        return p.resolve()
    # buscar en cwd
    p_cwd = Path.cwd() / p
    if p_cwd.exists():
        return p_cwd.resolve()
    # buscar en la misma carpeta del script
    script_dir = Path(__file__).parent
    p_script = script_dir / p
    if p_script.exists():
        return p_script.resolve()
    return None

def make_square_center(img: Image.Image) -> Image.Image:
    if img.width == img.height:
        return img
    side = min(img.width, img.height)
    left = (img.width - side) // 2
    top = (img.height - side) // 2
    return img.crop((left, top, left + side, top + side))

def get_resample():
    try:
        return Image.Resampling.LANCZOS
    except AttributeError:
        return Image.LANCZOS

def generate_icons(input_path: str, output_dir: str, crop_square: bool = True) -> int:
    input_p = find_input_path(input_path)
    if not input_p:
        print(f"❌ No se encontró la imagen: {input_path}")
        print("   (busqué en: ruta dada, carpeta actual y carpeta del script)")
        return 0

    try:
        img = Image.open(input_p).convert("RGBA")
    except Exception as e:
        print(f"❌ Error al abrir la imagen: {e}")
        return 0

    if crop_square:
        img = make_square_center(img)

    out_root = Path(output_dir)
    resample = get_resample()
    generated = 0

    for rel_path, size in SIZES.items():
        dest = out_root / rel_path
        dest.parent.mkdir(parents=True, exist_ok=True)
        try:
            resized = img.resize((int(size), int(size)), resample=resample)
            resized.save(dest, format="PNG")
            generated += 1
            print(f"✅ Generado: {dest} ({size}x{size})")
        except Exception as e:
            print(f"❌ Error generando {dest}: {e}")

    return generated

def main():
    parser = argparse.ArgumentParser(description="Generador de iconos para Flutter (Android/iOS).")
    parser.add_argument("-i", "--input", default="muayboran.png", help="Imagen de entrada (ruta).")
    parser.add_argument("-o", "--output", default="build_icons", help="Carpeta de salida.")
    parser.add_argument("--no-crop", action="store_true", help="No recortar a cuadrado (mantener aspect).")
    args = parser.parse_args()

    generated = generate_icons(args.input, args.output, crop_square=not args.no_crop)
    if generated == 0:
        print("\n⚠️ No se generó ninguna imagen. Revisa la ruta de entrada.")
        sys.exit(1)
    else:
        print(f"\n🎉 Se generaron {generated} imágenes en '{args.output}'.")

if __name__ == "__main__":
    main()
