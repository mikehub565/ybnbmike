from PIL import Image
import glob
import os

def convert(src, dst, quality=80):
    try:
        im = Image.open(src).convert('RGB')
    except Exception as e:
        print(f"skip {src}: {e}")
        return
    im.save(dst, 'WEBP', quality=quality, method=6)
    print(f"Created {dst}")

def main():
    patterns = ['*_1200.jpg','*_800.jpg','*_400.jpg','*.png','*.jpg']
    seen = set()
    for pat in patterns:
        for f in glob.glob(pat):
            base = os.path.splitext(f)[0]
            out = base + '.webp'
            if out in seen:
                continue
            convert(f, out)
            seen.add(out)

if __name__ == '__main__':
    main()
