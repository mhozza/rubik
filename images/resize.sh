for i in `find | grep -i ".jpg"`; do
  convert -resize '640x480' ${i} ${i}
  #echo "${i}";
  #echo "./zmensene/${i}";
done;

