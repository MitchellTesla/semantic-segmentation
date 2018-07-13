import requests
import os
import sys
import bz2
import math
import pathlib

from tqdm import tqdm

model_urls = [
    "https://github.com/matterport/Mask_RCNN/releases/download/v2.0/mask_rcnn_coco.h5",
]

my_path = os.path.dirname(__file__)

pathlib.Path(os.path.join(my_path, "models")).mkdir(parents=True, exist_ok=True)

if __name__ == "__main__":
    for url in model_urls:

        local_name = os.path.join(my_path, "models", url.split('/')[-1])
        print("%s => %s" % (url, local_name))

        response = requests.get(url, stream=True)

        decompressor = None
        if url.endswith(".bz2"):
            decompressor = bz2.BZ2Decompressor()
            local_name = ".".join(local_name.split('.')[:-1])

        total_size = int(response.headers.get('content-length', 0));

        block_size = 1024
        wrote = 0
        with open(local_name, "wb") as handle:
            for data in tqdm(response.iter_content(block_size), total=math.ceil(total_size//block_size), unit='KB'):
                if data:
                    wrote = wrote + len(data)
                    if decompressor is not None:
                        data = decompressor.decompress(data)
                    handle.write(data)

        if total_size != 0 and wrote != total_size:
            print("ERROR, something went wrong")