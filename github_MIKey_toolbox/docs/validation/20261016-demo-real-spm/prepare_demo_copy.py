"""Copy only real Stage 6/7 inputs, with hashes; never reuse old results."""
from pathlib import Path
import hashlib
import json
import shutil
import struct
import time
import uuid

ROOT = Path(r"K:\toolbox\MIKey_toolbox_main\MIKey_toolbox_main")
DEMO = ROOT / "demo_BIDS_dataset"
RECORD = ROOT / "docs/validation/20261016-demo-real-spm"
WORK = Path("C:/MIKeyRealSPM") / ("20261016-" + uuid.uuid4().hex[:8])
BIDS = WORK / "demo_BIDS_dataset"
RECORD.mkdir(parents=True, exist_ok=True)
WORK.mkdir(parents=True)

files = sorted((DEMO / "sub-001/func").glob("*_bold.nii"))
files += sorted((DEMO / "sub-001/func").glob("*_bold.json"))
files += sorted((DEMO / "sub-001/anat").glob("*_T2w.nii"))
files += sorted((DEMO / "sub-001/anat").glob("*_T2w.json"))
for pattern in ("*_desc-realign_bold.nii", "*_desc-mean_boldref.nii", "*_desc-boldbrain_mask.nii"):
    files += sorted((DEMO / "derivatives/MIKey/sub-001/func").glob(pattern))
for pattern in ("*_desc-masked_T2w.nii", "*_desc-anatbrain_mask.nii"):
    files += sorted((DEMO / "derivatives/MIKey/sub-001/anat").glob(pattern))
assert len(list((DEMO / "sub-001/func").glob("*_bold.nii"))) == 6
assert len(list((DEMO / "derivatives/MIKey/sub-001/func").glob("*_desc-realign_bold.nii"))) == 4
assert shutil.disk_usage(WORK).free > sum(p.stat().st_size for p in files) * 3

manifest = {"workspace": str(WORK), "bidsPath": str(BIDS), "files": [], "status": "copying"}
(RECORD / "workspace.json").write_text(json.dumps(manifest, indent=2) + "\n")
started = time.monotonic()
for source in files + [ROOT / "share_temp/Template_Mouse_v38.nii"]:
    destination = (BIDS / source.relative_to(DEMO)) if source.is_relative_to(DEMO) else WORK / "templates/Template_Mouse_v38.nii"
    destination.parent.mkdir(parents=True, exist_ok=True)
    digest = hashlib.sha256()
    with source.open("rb") as src, destination.open("xb") as dst:
        while block := src.read(8 * 1024 * 1024):
            digest.update(block)
            dst.write(block)
    shutil.copystat(source, destination)
    row = {"source": str(source), "copy": str(destination), "bytes": source.stat().st_size, "sha256": digest.hexdigest()}
    if source.name.endswith(".nii"):
        with destination.open("rb") as stream:
            header = stream.read(348)
        endian = "<" if struct.unpack_from("<i", header)[0] == 348 else ">"
        row["dimensions"] = struct.unpack_from(endian + "8h", header, 40)
        row["voxelSizes"] = struct.unpack_from(endian + "8f", header, 76)
    manifest["files"].append(row)
    (RECORD / "workspace.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print("COPIED", source.name, row["bytes"], flush=True)
manifest["status"] = "ready"
manifest["seconds"] = time.monotonic() - started
(RECORD / "workspace.json").write_text(json.dumps(manifest, indent=2) + "\n")
print("MIKEY_REAL_DEMO_COPY_READY", WORK, flush=True)
