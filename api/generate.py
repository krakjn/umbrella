#!/usr/bin/env python3
import argparse
import json
import os


def main():
    parser = argparse.ArgumentParser(description="Generate umbrella schema.json and schema.h")
    parser.add_argument("--version", required=True)
    parser.add_argument("--out", default="gen")
    args = parser.parse_args()

    os.makedirs(args.out, exist_ok=True)

    schema = {
        "greeting": "hello",
        "name": "umbrella",
        "version": args.version,
    }
    json_path = os.path.join(args.out, "schema.json")
    with open(json_path, "w", encoding="utf-8") as fh:
        json.dump(schema, fh)
        fh.write("\n")

    hdr_path = os.path.join(args.out, "schema.h")
    with open(hdr_path, "w", encoding="utf-8") as fh:
        fh.write(
            "#ifndef UMBRELLA_SCHEMA_H\n"
            "#define UMBRELLA_SCHEMA_H\n"
            "\n"
            '#define UMBRELLA_GREETING "hello"\n'
            '#define UMBRELLA_NAME "umbrella"\n'
            f'#define UMBRELLA_VERSION "{args.version}"\n'
            "\n"
            "#endif\n"
        )


if __name__ == "__main__":
    main()
