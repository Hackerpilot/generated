TESTCOMMAND="dscanner -s"

for i in $(seq 10000); do
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
