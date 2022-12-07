#!/bin/env bash
set -uo pipefail;

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

case "$(curl -s --max-time 2 -I https://www.google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) echo "HTTP connectivity is up";;
  5) echo "The web proxy won't let us through";;
  *) err "The network is down or very slow"; exit 1 ;;
esac

lflag='';
yflag='';
sflag='';
while getopts 'lys' flag; do
  case "${flag}" in
    l) lflag='true' ;;
    y) yflag='true' ;;
    s) sflag='true' ;;
    *) err "Unexpected flag"; exit 1 ;;
  esac
done

count=0;
# date=$(date); 
while IFS= read -r line; do

    filename="../output/$count-report.txt";

    curl=$(curl -Is --max-time 15 "$line");
    res=$?
    if test "$res" != "0"; then
        printf "the curl command failed for %s with: %s \n" "$line" "$res" | tee -a "$filename";
        
    else
        printf "\n";
        printf "\n";
        printf "The curl command was successful for %s. It exited with a status code of:" "$line" | tee -a "$filename";
        printf "%s" "$curl" | head -n 1 | tee -a "$filename";
        printf "\n";
        printf "\n";
        printf "COMMENCING ADDITIONAL TESTS:";
        printf "\n";
        printf "\n";

        if [[ -n $lflag ]]; then
            lighthouse "$line" --output json --output-path ../output/$count-lighthouse-result.json &
        else
            echo "NO Lighthouse test, try -l next time";
        fi

        if [[ -n $yflag ]]; then
            yellowlabtools "$line" > ../output/$count-yellow-lab-result.json &
        else
            echo "NO YellowLabTools test, try -y next time";
        fi

        if [[ -n $sflag ]]; then
            sitespeed.io "$line" --summary-detail --outputFolder ../output/$count-sitespeed-result/ &
        else
            echo "NO Sitespeed test, try -s next time";
        fi

    fi

done < urls.txt

wait;

# Output to STDOUT from gathered results.
if [[ -n $lflag ]]; then
    printf "Global Scores on Lighthouse:"
    printf "\n";
    printf "Performance:"
    printf "\n";
    jq '.categories.performance.score' ../output/$count-lighthouse-result.json;
    printf "Accessibility:"
    printf "\n";
    jq '.categories.accessibility.score' ../output/$count-lighthouse-result.json;
    printf "Best Practices:"
    printf "\n";
    jq '.categories."best-practices".score' ../output/$count-lighthouse-result.json;
    printf "SEO:"
    printf "\n";
    jq '.categories.seo.score' ../output/$count-lighthouse-result.json;
else
   echo "";
fi

if [[ -n $yflag ]]; then
    printf "Global Score on Yellow Labs:"
    jq '.scoreProfiles.generic.globalScore' ../output/$count-yellow-lab-result.json;
else
    echo "";

fi

if [[ -n $sflag ]]; then
    echo "";
else
    echo "";
fi