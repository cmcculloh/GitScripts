for file in functions/*

do
	if [ -d "$file" ]; then
		#echo "Directory: $file";

		for file2 in $file

		do
			if [ -d "$file2" ]; then
				#echo "Directory: $file2";
				continue
			else
				#echo "File2: $file2";
				source $file2
			fi
		done

		continue
	else
		#echo "File: $file";
		source $file
	fi
done