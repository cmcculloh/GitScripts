$0 ~ dsprefix {
	dssuffix = dssuffix "$"
	if ($0 ~ dssuffix) {
		# the prefix is the same length for all data source files
		print substr($0, length(dsprefix) + 1, length() - (length(dsprefix) + length(dssuffix) - 1))
	}
}