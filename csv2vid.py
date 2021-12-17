#!/usr/bin/env python3
'''
This script converts a csv to an mp4.
Run it like this:  ./csv2vid.py waterfall-471x265-rank5.csv.gz
The filename should contain `-{width}x{height}`.
'''

## requires `pip3 install pillow numpy` and `brew install ffmpeg`
from PIL import Image
import numpy as np
import csv, gzip, shutil, re, sys
import subprocess
from pathlib import Path

tmp_dir = Path('tmp-dir')
def clean_tmp_dir():
    tmp_dir.mkdir(exist_ok=True)
    for p in tmp_dir.iterdir(): p.unlink()


# Choose input file
if sys.argv[1:]:
  csv_path = Path(sys.argv[1])
else:
  csv_path = max(Path().glob('waterfall*.csv.gz'), key=lambda p:p.stat().st_mtime)  # newest!
  print(f'Converting newest csv: {csv_path}\n')

# Parse size
vid_width, vid_height = [int(d) for d in re.match(r'.*[_-]([0-9]+)x([0-9]+)[-_\.]', str(csv_path)).groups()]
print(f'{vid_width}x{vid_height} = {vid_width*vid_height}')

# Get first row, reshape as np matrix, turn into image.
pixelmat = np.genfromtxt(csv_path,delimiter=',',dtype=np.int16)  # Does it need to be float?  Should I round it?
print(f'pixel value range =', (pixelmat.min(), pixelmat.max()))
pixelmat = pixelmat.clip(min=0,max=255)
print(f'{pixelmat.shape=}')

# Compute a new even width & height, because mp4
width = vid_width // 2 * 2
height = vid_height // 2 * 2
print(f'{width}x{height}')

# Save frames into tmp_dir/#.png
clean_tmp_dir()
for frame in range(pixelmat.shape[0]):
    im = Image.fromarray(pixelmat[frame,].reshape((vid_height,vid_width)).astype(np.uint8))
    im = im.crop((0,0,width,height))
    im.save(tmp_dir / f'{frame}.png')

# Join the frames into an mp4
subprocess.run(f'ffmpeg -y -hide_banner -loglevel error -r 30 -i {tmp_dir}/%d.png -vf fps=30 -vcodec libx264 -pix_fmt yuv420p {csv_path}.mp4'.split())
print()
print(f'Wrote {csv_path}.mp4')
