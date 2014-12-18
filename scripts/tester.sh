TESTCOMMAND="dscanner -s"
TOTALRUNS=1000

rm -rf rejects

printf "Progress:            "
for i in $(seq $TOTALRUNS); do
	printf "\b\b\b\b\b\b\b\b\b\b\b"
	printf "%5d/%5d" $i $TOTALRUNS
	FILE="file_$i.d"
	./generated > $FILE
	if [ $? -eq 0 ]; then
		$TESTCOMMAND $FILE 2>&1 > /dev/null
		if [ $? -ne 0 ]; then
			mkdir -p rejects
			cp $FILE rejects/
		fi
	fi
	rm -f $FILE
done
printf "\nDone\n"
echo $(ls rejects/ | wc -l) "/ $TOTALRUNS files failed"
