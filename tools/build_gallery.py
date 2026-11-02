"""Create portable Markdown galleries from the actual emulator captures."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SHOTS = ROOT / "docs" / "screenshots"
FONT = ImageFont.truetype(str(ROOT / "assets/fonts/Poppins-Medium.ttf"), 14)

def contact_sheet(files, destination, columns, width):
    height = round(width * 896 / 414)
    rows = (len(files) + columns - 1) // columns
    board = Image.new("RGB", (columns * (width + 20) + 20, rows * (height + 50) + 20), "#eff1f5")
    draw = ImageDraw.Draw(board)
    for i, path in enumerate(files):
        x, y = 20 + (i % columns) * (width + 20), 20 + (i // columns) * (height + 50)
        screenshot = Image.open(path).convert("RGB")
        screenshot.thumbnail((width, height), Image.Resampling.LANCZOS)
        board.paste(screenshot, (x, y))
        draw.text((x, y + height + 9), path.stem, font=FONT, fill="#3a3943")
    board.save(destination, optimize=True)

def main():
    files = sorted(SHOTS.glob("*.png"))
    if not files:
        raise SystemExit("Run the integration screenshot test first.")
    contact_sheet(files, ROOT / "docs" / "all-screens.jpg", 6, 207)
    selected = [SHOTS / name for name in (
        "12-home.png", "16-categories-all.png", "18-job-description.png", "24-profile.png")]
    if all(path.exists() for path in selected):
        contact_sheet(selected, ROOT / "docs" / "main-preview.png", 4, 340)
    lines = [
        "# 界面截图索引", "",
        "以下截图由 Android 15 模拟器运行 Flutter App 后直接生成，原始大小为 828 × 1792 像素。",
        "对应 414 × 896 的设计尺寸；这是实际页面截图，不是设计稿导出。", "",
        "![全部界面概览](all-screens.jpg)", "",
        "| 序号 | 界面 / 状态 | 原始截图 |", "| --- | --- | --- |",
    ]
    for path in files:
        number, label = path.stem.split("-", 1)
        lines.append(f"| {number} | {label.replace('-', ' ')} | [查看截图](screenshots/{path.name}) |")
    lines += ["", "## Pixso 参考", "", "原始 30 张设计画板保存在 [design](design/) 中，页面映射见 [设计实现对照](DESIGN_MAPPING.md)。", ""]
    (ROOT / "docs" / "SCREENSHOTS.md").write_text("\n".join(lines), encoding="utf-8")
    print(f"Gallery written: {len(files)} screenshots.")

if __name__ == "__main__":
    main()
