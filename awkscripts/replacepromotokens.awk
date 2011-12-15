token {
	gsub(token, promouri, $0)
}
titletoken {
	gsub(titletoken, tagtitle, $0)
}
desctoken {
	gsub(desctoken, tagmetadesc, $0)
}
kwtoken {
	gsub(kwtoken, tagmetakeywords, $0)
}
{
	# replace unix line endings with windows...
	gsub(/$/,"\r")
	print $0
}