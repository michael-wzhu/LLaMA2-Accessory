#!/bin/bash

pretrained_path=$1
pretrained_type=meta_ori
llama_config="$2"
tokenizer_path="$3"
data_config=configs/finetune/sg/dialog_lima.yaml

data_parallel=fsdp
model_parallel=2

exp_name=finetune/sg/dialog_lima_13B
echo "exp name: $exp_name"
mkdir -p output/"$exp_name"

torchrun --master_port=1112 --nproc_per_node=8 main_finetune.py \
--output_dir output/"$exp_name" --epochs 4 --warmup_epochs 0.5 \
--batch_size 4 --accum_iter 8 --num_workers 4 \
--max_words 2048 \
--lr 0.00003 --min_lr 0.000005 --clip_grad 2 --weight_decay 0.02 \
--data_parallel "$data_parallel" --model_parallel_size "$model_parallel" --checkpointing \
--llama_type llama --llama_config "$llama_config" --tokenizer_path "$tokenizer_path" \
--no_visual \
--pretrained_path "$pretrained_path" --pretrained_type="$pretrained_type" \
--data_config $data_config --dialog \
2>&1 | tee -a output/"$exp_name"/output.log

echo "exp name: $exp_name"