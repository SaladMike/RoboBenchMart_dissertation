#!/usr/bin/env bash
set -Ee -o pipefail
cd /root/autodl-tmp/RoboBenchMart_dissertation
trap 'rc=$?; printf "%s\n" "$rc" > "logs/octo_parallel_20260928_021558_w0.exit"' EXIT
source /root/miniconda3/etc/profile.d/conda.sh
conda activate dsynth
set -u
export MS_ASSET_DIR=/root/autodl-tmp/robobenchmart-cache/maniskill
export VK_ICD_FILENAMES=/etc/vulkan/icd.d/nvidia_icd.json
export XDG_RUNTIME_DIR=/root/autodl-tmp/robobenchmart-cache/xdg-runtime
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
export NO_PROXY=localhost,127.0.0.1,::1
export no_proxy="$NO_PROXY"
export PYTHONUNBUFFERED=1

# Required: --model {octo|pi0|pi05}
MODEL=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model)
      MODEL="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -z "$MODEL" ]]; then
  echo "Error: --model is required (octo|pi0|pi05)" >&2
  exit 1
fi

if [[ "$MODEL" != "octo" && "$MODEL" != "pi0" && "$MODEL" != "pi05" ]]; then
  echo "Error: --model must be one of: octo, pi0, pi05" >&2
  exit 1
fi

EVAL_SCRIPT="scripts/eval_policy_client.py"

RUN_TS=$(date +%Y%m%d_%H%M%S)
SUBDIR_PREFIX="${MODEL}_"
SUBDIR_SUFFIX="_${RUN_TS}"

NUM_TRAJ=30

NET_PARAMS="--host=127.0.0.1 --port=8000"
EVAL_PARAMS_BOARD="--max-horizon 750 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_FRIDGE="--max-horizon 500 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_SHOWC="--max-horizon 1000 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_FLOOR="--max-horizon 750 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_BASKET="--max-horizon 600 --num-traj ${NUM_TRAJ} --save-video"

#TRAIN
# =========================================================
# move_from_board_to_board
# =========================================================
printf "START config=18 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/open_showcase/ \
--json-path demo_envs/open_showcase/demos/motionplanning/open_showcase_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}open_showcase_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_SHOWC > "logs/octo_parallel_20260928_021558_config18.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config18.log" || true)" != 1 ]; then echo "Incomplete result for config 18" >&2; exit 3; fi
printf "DONE config=18 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=20 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/pick_from_floor/ \
--json-path demo_envs/pick_from_floor/demos/motionplanning/pick_from_floor_beans_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}floor_beans_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR > "logs/octo_parallel_20260928_021558_config20.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config20.log" || true)" != 1 ]; then echo "Incomplete result for config 20" >&2; exit 3; fi
printf "DONE config=20 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=24 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/pick_to_basket \
--json-path demo_envs/pick_to_basket/demos/motionplanning/pick_to_basket_stars_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_stars_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET > "logs/octo_parallel_20260928_021558_config24.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config24.log" || true)" != 1 ]; then echo "Incomplete result for config 24" >&2; exit 3; fi
printf "DONE config=24 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=27 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e MoveFromBoardToBoardVanishContEnv \
--scene-dir demo_envs/test_unseen_scenes_move_from_board_to_board_vanish \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}board_vanish_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD --start-seed 42000 > "logs/octo_parallel_20260928_021558_config27.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config27.log" || true)" != 1 ]; then echo "Incomplete result for config 27" >&2; exit 3; fi
printf "DONE config=27 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=38 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e MoveFromBoardToBoardFantaContEnv \
--scene-dir demo_envs/test_unseen_items_move_from_board_to_board_fanta \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}board_fanta_ood${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD --start-seed 42000 > "logs/octo_parallel_20260928_021558_config38.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config38.log" || true)" != 1 ]; then echo "Incomplete result for config 38" >&2; exit 3; fi
printf "DONE config=38 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=41 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickToBasketContNestleEnv \
--scene-dir demo_envs/test_unseen_items_pick_to_basket \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_nestle_ood${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET --start-seed 42000 > "logs/octo_parallel_20260928_021558_config41.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config41.log" || true)" != 1 ]; then echo "Incomplete result for config 41" >&2; exit 3; fi
printf "DONE config=41 at %s\n" "$(date -u +%FT%TZ)"
printf "WORKER_DONE at %s\n" "$(date -u +%FT%TZ)"
