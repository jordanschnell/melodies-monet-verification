#!/bin/bash --login

module load hpss

hsi mkdir -p /5year/BMC/wrf-chem/aq_verification/${START_TIME}

if [[ "${model_type}" == "regional_smoke" ]]; then
htar -cvf /5year/BMC/wrf-chem/aq_verification/${START_TIME}/aq.nrt.verification.${START_TIME}.tar ${DIRTOARCHIVE}/*
fi

cd ${DIRTOARCHIVE2}
tar -czvf aq.nrt.verification.${model_type}.raw.${START_TIME}.tar.gz *
hsi put aq.nrt.verification.${model_type}.raw.${START_TIME}.tar.gz : /5year/BMC/wrf-chem/aq_verification/${START_TIME}/

