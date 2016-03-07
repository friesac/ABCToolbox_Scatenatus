#!/bin/bash

set -x
path_to_results=$1
population=$2
model=$3
components=$4
params=$5
stats=$6

#------ Just some formatting for the script -----
bold=$(tput bold)
normal=$(tput sgr0)

echo ""
echo "-------- We're preparing the calibration simulations of ${bold}${model}${normal} for ${bold}${population}${normal}-------------"

cd $path_to_results
cp $HOME/Scate_msat/binaries/PLS_Summary.r .

sed "s/dummy_model/$model/g" -i PLS_Summary.r
sed "s/dummy_components/$components/g" -i PLS_Summary.r
sed "s/dummy_params/$params/g" -i PLS_Summary.r
sed "s/dummy_stats/$stats/g" -i PLS_Summary.r

echo ""
echo "Here is the header line from your calibration simulation file:"
headcheck="head *_sampling1.txt"
$headcheck
echo ""
echo "Your calibration file has this many lines"
linecheck="wc -l *_sampling1.txt"
$linecheck

echo ""
echo "Now you'll run the Rscript for the calibration samples from the results directory: ${bold}Rscript PLS_Summary.r${normal}"
echo ""
