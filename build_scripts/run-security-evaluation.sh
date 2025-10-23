#!/bin/bash
set -e

# CORE=$1
BENCHMARK1=$1
BENCHMARK2=$2

SIGNALS=()

# Branch predictor state
BRACH_PREDICTOR_ENTRIES=8
BRACH_PREDICTOR_ENTRIES=$((BRACH_PREDICTOR_ENTRIES - 1))
iter=`seq 0 1 ${BRACH_PREDICTOR_ENTRIES}`
# for i in $iter; do
  # SIGNALS+=( "TOP.Core.pipeline.BranchTargetPredictor.entries_${i}_pc" )
  # SIGNALS+=( "TOP.Core.pipeline.BranchTargetPredictor.entries_${i}_target" )
# done

ICACHE_SETS=2
ICACHE_WAYS=2

# Instruction cache state
ICACHE_SETS=$((ICACHE_SETS - 1))
ICACHE_WAYS=$((ICACHE_WAYS - 1))
siter=`seq 0 1 ${ICACHE_SETS}`
witer=`seq 0 1 ${ICACHE_WAYS}`
# for s in $siter; do
#   for w in $witer; do
    # SIGNALS+=( "TOP.Core.pipeline.cache_ibus_cache_${s}_${w}_tag" )
    # SIGNALS+=( "TOP.Core.pipeline.cache_ibus_cache_${s}_${w}_valid" )
    # SIGNALS+=( "TOP.Core.pipeline.cache_ibus_cache_${s}_${w}_value" )
#   done
# done

DCACHE_SETS=8
DCACHE_WAYS=2

# Data cache state
DCACHE_SETS=$((DCACHE_SETS - 1))
DCACHE_WAYS=$((DCACHE_WAYS - 1))
siter=`seq 0 1 ${DCACHE_SETS}`
witer=`seq 0 1 ${DCACHE_WAYS}`
# for s in $siter; do
#   for w in $witer; do
#     SIGNALS+=( "TOP.Core.pipeline.cache_dbus_cache_${s}_${w}_tag" )
#     SIGNALS+=( "TOP.Core.pipeline.cache_dbus_cache_${s}_${w}_valid" )
#     SIGNALS+=( "TOP.Core.pipeline.cache_dbus_cache_${s}_${w}_value" )
#   done
# done

# if [[ "${CORE}" == "ExtMem" ]]; then

#   # Instruction latency attack (Nemesis)
#   SIGNALS+=( "TOP.Core.pipeline.writeback.arbitration_isDone" )

# echo "${SIGNALS[*]}"

# elif [[ "${CORE}" == "dynamicExtMem" ]]; then

#   # Port contention attack
#   ALUS=4
#   iter=`seq 1 1 ${ALUS}`
#   for i in $iter; do
#     SIGNALS+=( "TOP.Core.pipeline.Scheduler_RS_EX_ALU${i}_isAvailable" )
#   done

#   SIGNALS+=( "TOP.Core.pipeline.Scheduler_RS_EX_MUL1_isAvailable" )

#     # Instruction latency attack (Nemesis)
#   SIGNALS+=( "TOP.Core.pipeline.retirementStage.arbitration_isDone" )

# echo "${SIGNALS[*]}"

# else
#   echo "Invalid Core: '${CORE}'"
#   exit 1
# fi

SIGNALS+=( "main.top.soc_top.corew_proc.core_0.fetchStage.dirPred.m.gHistReg.m_hist")
SIGNALS+=( "main.top.soc_top.corew_proc.core_0.fetchStage.brTarget__h176719")
SIGNALS+=( "main.top.soc_top.corew_proc.core_0.fetchStage.nextAddrPred.pred")

for i in `seq 0 1 15`; do
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.fetchStage.ras.stack_${i}_lat_0")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.fetchStage.ras.stack_${i}_lat_1")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.fetchStage.ras.stack_${i}_rl")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.fetchStage.ras.valids_${i}_lat_0")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.fetchStage.ras.valids_${i}_lat_1")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.fetchStage.ras.valids_${i}_lat_2")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.fetchStage.ras.valids_${i}_rl")
done

for i in `seq 0 1 31`; do
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.rob.m_row_0_${i}.m_pc")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.rob.m_row_1_${i}.m_pc")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.rob.m_valid_0_${i}_lat_0")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.rob.m_valid_0_${i}_lat_1")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.rob.m_valid_0_${i}_rl")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.rob.m_valid_1_${i}_lat_0")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.rob.m_valid_1_${i}_lat_1")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.rob.m_valid_1_${i}_rl")
done

for i in `seq 0 1 3`; do
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.coreFix_memExe_dMem_cache_m_banks_0_pipeline.m_dataRam_${i}_bram.ADDRA")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.coreFix_memExe_dMem_cache_m_banks_0_pipeline.m_dataRam_${i}_bram.ADDRB")
  SIGNALS+=( "main.top.soc_top.corew_proc.core_0.fetchStage.iMem.cache.m_pipeline.m_dataRam_${i}_bram.ADDRA")
done

echo "SIGNALS:\n${SIGNALS[*]}"

###################################################################################################
check () {
  echo "+ diff $1 $2"
  diff $1 $2
  if [ $? -ne 0 ]; then echo "Leak detected" && exit 1 ; fi
}

# cd ${BENCHMARK}

# make clean

###################################################################################################
for SIGNAL in ${SIGNALS[@]}
do

  # 1. Run the experiments
  # for EXP in `grep EXPERIMENT main.c | sed -E 's/#.*EXPERIMENT_(.*)_(.*)/\1_\2/'`
  # do
  #   (
  #     set -x
  #     rm -f main.o
  #     EXPERIMENT=EXPERIMENT_${EXP} CORE=${CORE} make ${BENCHMARK}-linear.vcd
  #     EXPERIMENT=EXPERIMENT_${EXP} CORE=${CORE} make ${BENCHMARK}-folded.vcd
  #     cp ${BENCHMARK}-linear.vcd     ${BENCHMARK}-${EXP}-linear.vcd
  #     cp ${BENCHMARK}-folded.vcd ${BENCHMARK}-${EXP}-folded.vcd
      ${VCDCAT} ${BENCHMARK1} ${SIGNAL} > ${BENCHMARK1}-${SIGNAL}.vcdcat
      ${VCDCAT} ${BENCHMARK2} ${SIGNAL} > ${BENCHMARK2}-${SIGNAL}.vcdcat
      check ${BENCHMARK1}-${SIGNAL}.vcdcat ${BENCHMARK2}-${SIGNAL}.vcdcat
  #   )
  # done

  # 2. Check Molnar's form
  # for PARTITION in `grep EXPERIMENT main.c | sed -E 's/#.*EXPERIMENT_(.*)_.*/\1/' | uniq`
  # do
  #   for EXP in `grep EXPERIMENT_${PARTITION} main.c | sed -E "s/#.*EXPERIMENT_${PARTITION}_(.*)/\1/" | uniq`
  #   do
  #     check ${BENCHMARK}-${SIGNAL}-${PARTITION}_1-linear.vcdcat ${BENCHMARK}-${SIGNAL}-${PARTITION}_${EXP}-linear.vcdcat
  #   done
  # done

  # # 3. Check folded form
  # for PARTITION in `grep EXPERIMENT main.c | sed -E 's/#.*EXPERIMENT_(.*)_.*/\1/' | uniq`
  # do
  #   for EXP in `grep EXPERIMENT_${PARTITION} main.c | sed -E "s/#.*EXPERIMENT_${PARTITION}_(.*)/\1/" | uniq`
  #   do
  #     check ${BENCHMARK}-${SIGNAL}-${PARTITION}_1-folded.vcdcat ${BENCHMARK}-${SIGNAL}-${PARTITION}_${EXP}-folded.vcdcat
  #   done
  # done

  echo "PASS!"

done

echo "All checks passed!"
