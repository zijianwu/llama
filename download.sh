# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the GNU General Public License version 3.

# PRESIGNED_URL only valid for 7 days
PRESIGNED_URL="https://dobf1k6cxlizq.cloudfront.net/*?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kb2JmMWs2Y3hsaXpxLmNsb3VkZnJvbnQubmV0LyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2NzgzNjk4Mjl9fX1dfQ__&Signature=MvlXdrf0Tm3C3FglKQHUPZzXz72vOTSZIqCCXWm-89G7DuNSnYBsgcAVH~1iU8EX~ihb~5u~DnrvZawPxw4oZ7LW5v00SHd9Dqxg~XG3HDwL3o6lxiXgPqScJ2aGI2D3ChoZGAeIHwo53els6FVIbOZK~0JiQaZOp2t-rWVToQTPkJxQOn0CgCOBuyB8C9l1Fch9E5F4~8ryp-Tt8co76U1PkOLs2RAQptOIRPjOJfvLHsVPILlS3h~0rbry4MIpeL-9AmtR9MhViU8BBWbrlvtPCb-FoHUDghLNTpWi0l~i1uM7AYZ29QruuHpviXt9guJp1mzTWZcyhtqJcBOVfg__&Key-Pair-Id=K231VYXPC1TA1R"             # replace with presigned url from email
MODEL_SIZE="65B" # 7B,13B,30B,65B  # edit this list with the model sizes you wish to download
TARGET_FOLDER="/home/zwu/projects/llama/default_model_weights"             # where all files should end up

declare -A N_SHARD_DICT

N_SHARD_DICT["7B"]="0"  # MP = 1
N_SHARD_DICT["13B"]="1" # MP = 2
N_SHARD_DICT["30B"]="3" # MP = 4
N_SHARD_DICT["65B"]="7" # MP = 8

echo "Downloading tokenizer"
wget ${PRESIGNED_URL/'*'/"tokenizer.model"} -O ${TARGET_FOLDER}"/tokenizer.model"
wget ${PRESIGNED_URL/'*'/"tokenizer_checklist.chk"} -O ${TARGET_FOLDER}"/tokenizer_checklist.chk"

(cd ${TARGET_FOLDER} && md5sum -c tokenizer_checklist.chk)

for i in ${MODEL_SIZE//,/ }
do
    echo "Downloading ${i}"
    mkdir -p ${TARGET_FOLDER}"/${i}"
    for s in $(seq -f "0%g" 0 ${N_SHARD_DICT[$i]})
    do
        wget ${PRESIGNED_URL/'*'/"${i}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${i}/consolidated.${s}.pth"
    done
    wget ${PRESIGNED_URL/'*'/"${i}/params.json"} -O ${TARGET_FOLDER}"/${i}/params.json"
    wget ${PRESIGNED_URL/'*'/"${i}/checklist.chk"} -O ${TARGET_FOLDER}"/${i}/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${i}" && md5sum -c checklist.chk)
done