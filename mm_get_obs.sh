#!/bin/bash
#
#source /mnt/lfs4/BMC/rtwbl/melodies-monet/miniconda3/bin/activate monet
source /scratch1/BMC/wrf-chem/Jordan/miniconda3/bin/activate melodies-monet
module load ncl
#
DATE=/bin/date
#
#Set up the date strings
todays_date=`${DATE} +%Y%m%d -d ${START_TIME}`
endday_date=`${DATE} +%Y%m%d -d ${END_TIME}`
end_date=`${DATE} +%Y%m%d -d ${END_TIME}`

# Today variables 
YYYY_today=`${DATE} +%Y -d "${todays_date}"` # with activation_offset = -24, this brings us to the current time
MM_today=`${DATE} +%m -d "${todays_date}"`
DD_today=`${DATE} +%d -d "${todays_date}"`
HH_today=`${DATE} +%H -d "${todays_date}"`

YYYY_endday=`${DATE} +%Y -d "${END_TIME}"` # with activation_offset = -24, this brings us to the current time
MM_endday=`${DATE} +%m -d "${END_TIME}"`
DD_endday=`${DATE} +%d -d "${END_TIME}"`
HH_endday=`${DATE} +%H -d "${END_TIME}"`

# Dates also need to be for yesterday
start_time_reformat=`${DATE} -d "${YYYY_today}${MM_today}${DD_today}" +%Y-%m-%d`
end_time_reformat=`${DATE} -d "${YYYY_endday}${MM_endday}${DD_endday}" +%Y-%m-%d`
end_time_reformat_openaq=`${DATE} -d "${YYYY_endday}${MM_endday}${DD_endday} + 23 hours" "+%Y-%m-%d %H:00"`

workdir=${WORKDIR}
mkdir -p ${workdir}
cd ${workdir}

scriptsdir=${SCRIPTS_DIR} #/home/role.rap-chem/scripts/melodies-monet_offline
# First remove any test5.nc
#rm -f test5.nc

if [[ "${OBSTYPE}" == "AERONET" ]]; then
#call and run reformat_airnow_rapchemtest.py with appropriate variables
python ${scriptsdir}/reformat_aeronet_rapchemtest.py ${start_time_reformat} ${end_time_reformat}
if [[ -e test5.aeronet.nc ]]; then
  mv test5.aeronet.nc test5.aeronet.${todays_date}-${endday_date}.nc
  cp ${scriptsdir}/make_westoreastof97_aeronet.ncl .
  ncl make_westoreastof97_aeronet.ncl
else
  echo "test5.nc is missing for aeronet!"
  #exit 1
fi
fi

if [[ "${OBSTYPE}" == "AIRNOW" ]]; then
python ${scriptsdir}/reformat_airnow_rapchemtest.py ${start_time_reformat} ${end_time_reformat}
if [[ -e test5.airnow.nc ]]; then
  mv test5.airnow.nc test5.airnow.${todays_date}-${endday_date}.nc   #moving the test5.nc generated from reformat to test5.nc.{todays_date}
  cp ${scriptsdir}/make_westoreastof97_airnow.ncl .
  ncl make_westoreastof97_airnow.ncl
else
  echo "test5.nc is missing for airnow!"
  #exit 1
fi

if [[ -e cur_aqi_ozone.kml ]]; then
   mv cur_aqi_ozone.kml cur_aqi_ozone.${todays_date}-${endday_date}.kml
else
  echo "Did not download ozone AQI data!"
fi
if [[ -e cur_aqi_pm25.kml ]]; then
   mv cur_aqi_pm25.kml cur_aqi_pm25.${todays_date}-${endday_date}.kml
else
  echo "Did not download PM.25 AQI data!"
fi
if [[ -e cur_aqi_combined.kml ]]; then
   mv cur_aqi_combined.kml cur_aqi_combined.${todays_date}-${endday_date}.kml
else
  echo "Did not download combined AQI data!"
fi
#
fi


if [[ "${OBSTYPE}" == "ISH-LITE" ]]; then
conda deactivate
conda deactivate
#source /mnt/lfs4/BMC/rtwbl/melodies-monet/miniconda3/bin/activate melodies-monet
source /scratch1/BMC/wrf-chem/Jordan/miniconda3/bin/activate melodies-monet
# 
#melodies-monet get-ish-lite -s ${start_time_reformat} -e ${end_time_reformat} --verbose --debug --no-compress --box1=0. --box2=-140. --box3=90. --box4=-50.
#melodies-monet get-ish-lite -s ${start_time_reformat} -e ${end_time_reformat} --verbose --debug --no-compress --num-workers=13 # Box hardcoded in monetio/obs/ish_lite.py
melodies-monet get-ish-lite -s ${start_time_reformat} -e ${end_time_reformat} --box 0 -140 90 -50 --verbose --debug --num-workers=13
if [[ -e ISH-Lite_${todays_date}_${endday_date}.nc ]]; then
   echo "obs file created for ISH/ISD"
   mv ISH-Lite_${todays_date}_${endday_date}.nc test5.ish-lite.${todays_date}-${endday_date}.nc
   cp ${scriptsdir}/make_westoreastof97_ish-lite.ncl .
   ncl make_westoreastof97_ish-lite.ncl
else
   echo "test5 is missing for ISH!"
   #exit 1
fi

fi
#
#
# .. openAQ
#melodies-monet get-openaq -s ${start_time_reformat} -e ${end_time_reformat_openaq} --verbose --debug --num-workers=13

if [[ "${OBSTYPE}" == "ISH" ]]; then
conda deactivate 
conda deactivate
#source /mnt/lfs4/BMC/rtwbl/melodies-monet/miniconda3/bin/activate monet
source /scratch1/BMC/wrf-chem/Jordan/miniconda3/bin/activate melodies-monet
## ISH (grabs the ISH data that includes visibility)
python ${scriptsdir}/reformat_ish.py ${start_time_reformat} ${end_time_reformat}
if [[ -e test5.ish.nc ]]; then
   echo "obs file created for ISH/ISD"
   mv test5.ish.nc test5.ish.${todays_date}-${endday_date}.nc
else
   echo "test5 is missing for ISH!"
#   #exit 1
fi
# TODO add the function to the _cli.py in the monet environment
fi

if [[ "${OBSTYPE}" == "HMS" ]]; then
## Get the HMS smoke polygons and fire locations
if [[ -e /lfs4/BMC/public/data/grids/nesdis/hms_fire/text/hms_fire${YYYY_today}${MM_today}${DD_today}.txt ]] ;then
   echo "Found HMS fire locations"
   cp /lfs4/BMC/public/data/grids/nesdis/hms_fire/text/hms_fire${YYYY_today}${MM_today}${DD_today}.txt hms_fire_${todays_date}.-${endday_date}txt
else
   wget https://satepsanone.nesdis.noaa.gov/pub/FIRE/web/HMS/Fire_Points/Text/${YYYY_today}/${MM_today}/hms_fire${todays_date}.txt
   mv hms_fire${todays_date}.txt hms_fire_${todays_date}.-${endday_date}txt

fi
#if [[ -e /lfs4/BMC/public/data/grids/nesdis/hms_smoke/kml/hms_smoke${YYYY_today}${MM_today}${DD_today}.kml ]]; then
##   echo "Found HMS smoke polygons"
#   cp /lfs4/BMC/public/data/grids/nesdis/hms_smoke/kml/hms_smoke${YYYY_today}${MM_today}${DD_today}.kml hms_smoke_${todays_date}.kml
#else
#   echo "HMS Smoke polygons are unavailable"
#fi
wget https://satepsanone.nesdis.noaa.gov/pub/FIRE/web/HMS/Smoke_Polygons/KML/${YYYY_today}/${MM_today}/hms_smoke${YYYY_today}${MM_today}${DD_today}.kml
if [[ -e hms_smoke${YYYY_today}${MM_today}${DD_today}.kml ]]; then
   mv hms_smoke${YYYY_today}${MM_today}${DD_today}.kml hms_smoke_${YYYY_today}${MM_today}${DD_today}.kml
else
   echo "HMS Smoke polygons are unavailable"
fi
fi

exit 0
