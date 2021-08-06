######################################################
# Filter bank variables
######################################################
export FBOUTPUT_CMN=$(echo $CMN_OUTPUT_ROOT/fbs)
export FBOUTPUT_CMN_PLOTS_DAILY=$(echo $CMN_OUTPUT_ROOT/fbs/dailyPlots)
export FBOUTPUT_CMN_PLOTS_WEEKLY=$(echo $CMN_OUTPUT_ROOT/fbs/weeklyPlots)
export FBSTATOUTPUT_CMN=$(echo $CMN_OUTPUT_ROOT/fbs/stats)

export FBOUTPUT_BK=$(echo $BK_OUTPUT_ROOT/fbs)
export FBOUTPUT_BK_DPLOTS=$(echo $BK_OUTPUT_ROOT/fbs/dailyPlots)
export FBSTATOUTPUT_BK=$(echo $BK_OUTPUT_ROOT/fbs/stats)

export BKQ_OUTPUT_ROOT=$BK_OUTPUT_ROOT
export FBOUTPUT_BKQ=$(echo $BKQ_OUTPUT_ROOT/fbs-quiet)
export FBOUTPUT_BKQ_DPLOTS=$(echo $BKQ_OUTPUT_ROOT/fbs-quiet/dailyPlots)
export FBSTATOUTPUT_BKQ=$(echo $BKQ_OUTPUT_ROOT/fbs-quiet/stats)
