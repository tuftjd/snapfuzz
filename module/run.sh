#!/bin/bash

arg1=$1
cur=$(date +"%Y-%m-%d-%H:%M:%S")
out_dir="../snap_exp/snap_${arg1}_$cur"

case "$1" in
dicom)
  PROJECT_NAME="dicom"
  AFL_ARGS="-m 512 -i ./conf/in-dicom -P DICOM -E -K -R"
  TARGET_CONF=""
  TARGET_BINS=("./dcmqrscp")
  export DCMDICTPATH="./conf/dicom.dic"
  ;;
dicom-asan)
  PROJECT_NAME="dicom-asan"
  AFL_ARGS="-t 1000 -m none -i ./conf/in-dicom -P DICOM -E -K -R"
  TARGET_CONF=""
  TARGET_BINS=("./dcmqrscp-asan")
  export DCMDICTPATH="./conf/dicom.dic"
  ;;

dns)
  PROJECT_NAME="dns"
  AFL_ARGS="-m none -i ./conf/in-dns -P DNS -K -R"
  TARGET_CONF="-C ./conf/dnsmasq.conf"
  TARGET_BINS=("./dnsmasq")
  ;;
dns-asan)
  PROJECT_NAME="dns-asan"
  AFL_ARGS="-t 1000 -m none -i ./conf/in-dns -P DNS -K -R"
  TARGET_CONF="-C ./conf/dnsmasq.conf"
  TARGET_BINS=("./dnsmasq-asan")
  ;;

dtls)
  PROJECT_NAME="dtls"
  AFL_ARGS="-m 512 -i ./conf/in-dtls -P DTLS12 -q 3 -s 3 -E -K -R"
  TARGET_CONF=""
  TARGET_BINS=("./dtls-server")
  ;;
dtls-asan)
  PROJECT_NAME="dtls-asan"
  AFL_ARGS="-t 1000 -m none -i ./conf/in-dtls -P DTLS12 -q 3 -s 3 -E -K -R"
  TARGET_CONF=""
  TARGET_BINS=("./dtls-server-asan")
  ;;
tls)
  PROJECT_NAME="tls"
  AFL_ARGS="-m none -d -i ./conf/in-tls -x ./conf/tls.dict -P TLS -D 50000 -q 3 -s 3 -E -K -R -W 100"
  TARGET_CONF=""
  TARGET_BINS=("./openssl s_server -key ./key.pem -cert ./cert.pem -4 -naccept 1 -no_anti_replay")
  ;;
ftp)
  PROJECT_NAME="ftp"
  AFL_ARGS="-m 512 -i ./conf/in-ftp -x ./conf/ftp.dict -P FTP -t 10000 -q 3 -s 3 -E -R"
  TARGET_CONF="./conf/fftp.conf 2200"
  # TARGET_BINS=("./fftp" "./fftp-pthreadjoin")
  TARGET_BINS=("./fftp")
  ;;
ftp-asan)
  PROJECT_NAME="ftp-asan"
  AFL_ARGS="-t 1000 -m none -i ./conf/in-ftp -x ./conf/ftp.dict -P FTP -q 3 -s 3 -E -R"
  TARGET_CONF="./conf/fftp.conf 2200"
  TARGET_BINS=("./fftp-asan")
  ;;
ftp-tsan)
  PROJECT_NAME="ftp-tsan"
  AFL_ARGS="-t 1000 -m none -i ./conf/in-ftp -x ./conf/ftp.dict -P FTP -q 3 -s 3 -E -R"
  TARGET_CONF="./conf/fftp.conf 2200"
  TARGET_BINS=("./fftp-tsan")
  ;;
ftp-pth)
  PROJECT_NAME="ftp-pth"
  AFL_ARGS="-m 512 -i ./conf/in-ftp -x ./conf/ftp.dict -P FTP -q 3 -s 3 -E -R"
  TARGET_CONF="./conf/fftp.conf 2200"
  TARGET_BINS=("./fftp")
  export AFL_PRELOAD="./lib2pthread.so"
  ;;

rtsp)
  PROJECT_NAME="rtsp"
  AFL_ARGS="-m 512 -i ./conf/in-rtsp -x ./conf/rtsp.dict -P RTSP -q 3 -s 3 -E -K -R"
  TARGET_CONF="8554"
  TARGET_BINS=("./testOnDemandRTSPServer")
  ;;
rtsp-asan)
  PROJECT_NAME="rtsp-asan"
  AFL_ARGS="-t 1000 -m none -i ./conf/in-rtsp -x ./conf/rtsp.dict -P RTSP -q 3 -s 3 -E -K -R"
  TARGET_CONF="8554"
  TARGET_BINS=("./testOnDemandRTSPServer-asan")
  ;;

*)
  echo "Unknown command. Try one of {dicom,dns,dtls,ftp,rtsp}"
  exit 1
  ;;
esac


CMD="my-afl -A ./libsbr-afl.so -b ./libsbr-trace.so ${AFL_ARGS} -o ${out_dir} ${TARGET_BINS} ${TARGET_CONF} "
eval $CMD

