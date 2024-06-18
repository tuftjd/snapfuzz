#!/bin/bash


arg1=$1
cur=$(date +"%Y-%m-%d-%H:%M:%S")
out_dir="../afl_exp/afl_${arg1}_$cur"

case "$1" in
dicom)
  PROJECT_NAME="dicom"
  AFL_ARGS="-m 512 -i ./conf/in-dicom -N tcp://127.0.0.1/5158 -P DICOM -c ./conf/dicomclean.sh -D 10000 -E -K -R -W 5"
  TARGET_CONF=""
  TARGET_BINS=("./dcmqrscp")
  export DCMDICTPATH="./conf/dicom.dic"
  ;;
dns)
  PROJECT_NAME="dns"
  AFL_ARGS="-m 512 -i ./conf/in-dns -N tcp://127.0.0.1/5353 -P DNS -D 10000 -K -R"
  TARGET_CONF="-C ./conf/dnsmasq.conf"
  TARGET_BINS=("./dnsmasq")
  ;;
dtls)
  PROJECT_NAME="dtls"
  AFL_ARGS="-m 512 -i ./conf/in-dtls -N udp://127.0.0.1/20220 -P DTLS12 -D 10000 -q 3 -s 3 -E -K -R -W 2"
  TARGET_CONF=""
  TARGET_BINS=("./dtls-server")
  ;;
dtls-orig)
  PROJECT_NAME="dtls-orig"
  AFL_ARGS="-m 512 -i ./conf/in-dtls -N udp://127.0.0.1/20220 -P DTLS12 -D 10000 -q 3 -s 3 -E -K -R -W 30"
  TARGET_CONF=""
  TARGET_BINS=("./dtls-server")
  ;;
ftp)
  PROJECT_NAME="ftp"
  AFL_ARGS="-m 512 -i ./conf/in-ftp -N tcp://127.0.0.1/2200 -x ./conf/ftp.dict -P FTP -D 10000 -q 3 -s 3 -E -R -c ./conf/ftpclean.sh"
  TARGET_CONF="./conf/fftp.conf 2200"
  # TARGET_BINS=("./fftp" "./fftp-pthreadjoin" "./fftp-deffer" "./fftp-deffer-pthreadjoin")
  TARGET_BINS=("./fftp")
  ;;
rtsp)
  PROJECT_NAME="rtsp"
  AFL_ARGS="-m 512 -i ./conf/in-rtsp -N tcp://127.0.0.1/8554 -x ./conf/rtsp.dict -P RTSP -D 10000 -q 3 -s 3 -E -K -R"
  TARGET_CONF="8554"
  TARGET_BINS=("./testOnDemandRTSPServer")
  ;;
ftp-asan)
  PROJECT_NAME="ftp-asan"
  AFL_ARGS="-m none -i ./conf/in-ftp -N tcp://127.0.0.1/2200 -x ./conf/ftp.dict -P FTP -D 10000 -q 3 -s 3 -E -R -c ./conf/ftpclean.sh"
  TARGET_CONF="./conf/fftp.conf 2200"
  TARGET_BINS=("./fftp-asan")
  ;;
ftp-tsan)
  PROJECT_NAME="ftp-tsan"
  AFL_ARGS="-m none -i ./conf/in-ftp -N tcp://127.0.0.1/2200 -x ./conf/ftp.dict -P FTP -D 10000 -W 15 -q 3 -s 3 -E -R -c ./conf/ftpclean.sh"
  TARGET_CONF="./conf/fftp.conf 2200"
  TARGET_BINS=("./fftp-tsan")
  ;;
*)
  echo "Unknown command. Try one of {dicom,dns,dtls,ftp,rtsp}"
  exit 1
  ;;
esac

CMD="my-afl ${AFL_ARGS} -o ${out_dir} ${TARGET_BINS} ${TARGET_CONF} "
eval $CMD
