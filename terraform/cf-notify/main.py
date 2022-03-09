import base64
import zlib

def print_decoded(event, context):
    decoded_compressed = base64.b64decode(event['data'])
    decompressed = zlib.decompress(decoded_compressed)
    print(decompressed)
