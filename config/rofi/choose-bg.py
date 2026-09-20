"""Generate config.rasi using Material You."""

import argparse
import colorsys
import math
from importlib import import_module
from pathlib import Path

from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.hct import Hct
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.utils.color_utils import rgba_from_argb
from PIL import Image

BITMAP_SIZE = 128
SCRIPT_DIR = Path(__file__).parent
TEMPLATE_PATH = SCRIPT_DIR / "config-template.rasi"
OUTPUT_PATH = SCRIPT_DIR / "config.rasi"

SCHEMES: dict[str, str] = {
    "fruitsalad": "scheme_fruit_salad.SchemeFruitSalad",
    "expressive": "scheme_expressive.SchemeExpressive",
    "monochrome": "scheme_monochrome.SchemeMonochrome",
    "rainbow": "scheme_rainbow.SchemeRainbow",
    "tonalspot": "scheme_tonal_spot.SchemeTonalSpot",
    "neutral": "scheme_neutral.SchemeNeutral",
    "fidelity": "scheme_fidelity.SchemeFidelity",
    "content": "scheme_content.SchemeContent",
    "vibrant": "scheme_vibrant.SchemeVibrant",
}


def rgba_to_hex(rgba: tuple[int, ...]) -> str:
    return f"#{rgba[0]:02X}{rgba[1]:02X}{rgba[2]:02X}"


def optimal_size(width: int, height: int) -> tuple[int, int]:
    area = width * height
    target = BITMAP_SIZE**2
    scale = math.sqrt(target / area) if area > target else 1.0
    return max(1, round(width * scale)), max(1, round(height * scale))


def load_scheme(name: str) -> type:
    entry = SCHEMES.get(name, SCHEMES["vibrant"])
    module_name, class_name = entry.rsplit(".", 1)
    mod = import_module(f"materialyoucolor.scheme.{module_name}")
    return getattr(mod, class_name)


def extract_color(scheme: object, name: str) -> str:
    prop = getattr(MaterialDynamicColors, name)
    rgba = prop.get_hct(scheme).to_rgba()
    return rgba_to_hex(tuple(round(c) for c in rgba))


def shift_background_color(hex_color: str, lightdark: str) -> str:
    if lightdark == "light":
        return hex_color
    r, g, b = int(hex_color[1:3], 16), int(hex_color[3:5], 16), int(hex_color[5:7], 16)
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    s = min(s * 0.42, 0.40)
    v = min(v * 0.61, 0.13)
    r2, g2, b2 = colorsys.hsv_to_rgb(h, s, v)
    return f"#{round(r2 * 255):02X}{round(g2 * 255):02X}{round(b2 * 255):02X}"


def quantize_image(path: str) -> int:
    image = Image.open(path)
    w, h = image.size
    nw, nh = optimal_size(w, h)
    if nw < w or nh < h:
        image = image.resize((nw, nh), Image.Resampling.BICUBIC)

    pixel_data = image.tobytes()
    stride = len(image.mode)
    pixels = [
        (pixel_data[i], pixel_data[i + 1], pixel_data[i + 2], 255)
        for i in range(0, len(pixel_data), stride)
    ]
    colors = QuantizeCelebi(pixels, 128)
    return Score.score(colors)[0]


def generate_config(
    path: str,
    theme_path: str | None = None,
    height: int = 210,
    mode: str = "dark",
    scheme_name: str = "vibrant",
    transparency: str = "opaque",
) -> None:
    seed_argb = quantize_image(theme_path or path)
    hct = Hct.from_int(seed_argb)

    darkmode = mode == "dark"
    scheme_cls = load_scheme(scheme_name)
    scheme = scheme_cls(hct, darkmode, 0.0)

    background = shift_background_color(extract_color(scheme, "surface"), mode)
    foreground = extract_color(scheme, "onSurface")
    selected = extract_color(scheme, "primary")
    active = extract_color(scheme, "tertiary")
    urgent = extract_color(scheme, "error")

    surface_high = extract_color(scheme, "surfaceContainerHigh")
    background_alt = shift_background_color(surface_high, mode) + "80"

    half_height = (height - 40) // 2 - 10

    template = TEMPLATE_PATH.read_text()
    output = (
        template.replace("{{color-background}}", background)
        .replace("{{color-background-alt}}", background_alt)
        .replace("{{color-foreground}}", foreground)
        .replace("{{color-selected}}", selected)
        .replace("{{color-active}}", active)
        .replace("{{color-urgent}}", urgent)
        .replace("{{url-background}}", path)
        .replace("{{background-half-height}}", str(half_height))
    )

    OUTPUT_PATH.write_text(output)
    print(f"Generated {OUTPUT_PATH}")
    print(f"  seed: {rgba_to_hex(tuple(round(c) for c in rgba_from_argb(seed_argb)))}")
    print(f"  scheme: {scheme_name} ({'dark' if darkmode else 'light'})")
    print(f"  background: {background}")
    print(f"  selected: {selected}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)

    # ---- @! core arguments -------------------------------------------------------------
    parser.add_argument(
        "--path", type=str, required=True, help="path to wallpaper image"
    )
    parser.add_argument(
        "--theme-path",
        type=str,
        default=None,
        help="image to derive palette from (defaults to --path)",
    )
    parser.add_argument(
        "--height", type=int, default=210, help="theme image height in pixels"
    )

    # ---- @! these are not finished! I'll come back later -------------------------------
    parser.add_argument(
        "--scheme",
        type=str,
        default="vibrant",
        choices=SCHEMES.keys(),
        help="choose color scheme (note: experimental)",
    )
    parser.add_argument(
        "--mode",
        type=str,
        choices=["dark", "light"],
        default="dark",
        help="choose light or dark color theme (note: experimental)",
    )
    parser.add_argument(
        "--transparency",
        type=str,
        choices=["opaque", "transparent"],
        default="opaque",
        help="not implemented yet",
    )

    args = parser.parse_args()
    generate_config(
        path=args.path,
        theme_path=args.theme_path,
        height=args.height,
        mode=args.mode,
        scheme_name=args.scheme,
        transparency=args.transparency,
    )


if __name__ == "__main__":
    main()
