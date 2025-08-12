import uuid
import struct
import argparse

def uuid_to_windows_bytes(guid: uuid.UUID) -> bytes:
    fields = guid.fields

    return struct.pack(
        '<IHH',
        fields[0],
        fields[1],
        fields[2],
    ) + struct.pack(
        '>H',
        (fields[3] << 8) | fields[4]
    ) + guid.node.to_bytes(6, 'big')

def create_config_file(guid_str: str, filepath: str, output_file: str):
    try:
        guid = uuid.UUID(guid_str)
        guid_bytes = uuid_to_windows_bytes(guid)
    except ValueError as e:
        raise ValueError(f"Invalid GUID: {e}")

    filepath_bytes = filepath.encode('utf-16le')

    with open(output_file, 'wb') as f:
        f.write(guid_bytes)
        f.write(filepath_bytes)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate raw-byte config file with a disk GUID.")
    parser.add_argument("disk_guid", help="The disk GUID to use.")
    parser.add_argument("--file_path", default=r"\boot\conf", help="File path to include (default: \\boot\\conf)")
    parser.add_argument("--output_path", default="conf.meta", help="Output file path (default: conf.meta)")

    args = parser.parse_args()

    create_config_file(args.disk_guid, args.file_path, args.output_path)
