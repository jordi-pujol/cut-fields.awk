#!/usr/bin/awk -f
##
##	cut-fields - cut utility for fields.
##	Mimics the syntax and behaviour of the coreutils cut utility.
##
##	Examples:
##		echo "en un lugar de la Mancha de cuyo nombre no quiero acordarme" | \
##			./cut-fields.awk \
##				-v fields='-2,4-6,8-' \
##				-v FS='[,[:blank:]]' \
##				-v OFS=","  \
##				-v complement=y \
##				-v only_delimited=y
##

function usage(e1) {
	e1="usage: echo \"text\" | cut-fields.awk" \
"\n\tMimics the syntax and behaviour of the coreutils cut utility." \
"\n\tParameters are passed through variables:" \
"\n\t-v fields= select only these fields;" \
"\n\t\talso print any line that contains no delimiter character," \
"\n\t\tunless the only_delimited option is specified" \
"\n\t-v FS= delimiter may be a regular expression, optional," \
"\n\t\tif not specified will use the awk default field delimiter" \
"\n\t-v OFS= output delimiter, optional" \
"\n\t\tif not specified will use the awk default field output delimiter" \
"\n\t-v RS= record delimiter, optional," \
"\n\t\tif not specified will use the awk default record delimiter" \
"\n\t-v complement= complement the set of selected fields," \
"\n\t\tset to any character to enable" \
"\n\t-v only_delimited= do not print lines not containing delimiters," \
"\n\t\tset to any character to enable"
	print e1 > "/dev/stderr"
	exit 1
}

function bad_range() {
	printf("bad field range: %s\n", f) > "/dev/stderr"
	exit 1
}

BEGIN {
	if (! fields)
		usage()
	gsub("^[,[:blank:]]+|[,[:blank:]]+$", "", fields)
	if (split(fields, fieldsarray, "[,[:blank:]]+") == 0)
		usage()
	fieldsMin=""
	complement=complement
	only_delimited=only_delimited
	for (h in fieldsarray) {
		f=fieldsarray[h]
		if (f == "")
			continue
		m=split(f, g, "-")
		if (m == 1) {
			if (g[1] !~ "^[[:digit:]]+$" || g[1] < 1)
				bad_range()
		} else
			if (m == 2) {
				if ((g[1] == "" && g[2] == "") \
				|| (g[1] != "" && (g[1] !~ "^[[:digit:]]+$" || g[1] < 1)) \
				|| (g[2] != "" && (g[2] !~ "^[[:digit:]]+$" || g[2] < 1)) \
				|| (g[1] != "" && g[2] != "" && g[1] > g[2]))
					bad_range()
			} else
				bad_range()
		if (g[1] != "" && g[2] != "")
			for (i=g[1]; i <= g[2]; i++)
				flist[i]=0
		else
			if (g[2] != "")
				for (i=1; i <= g[2]; i++)
					flist[i]=0
			else {
				if (m == 2) {
					if (fieldsMin)
						bad_range()
					fieldsMin=g[1]
				}
				flist[g[1]]=0
			}
	}
}
{
	if (fieldsMin && fieldsMin < NF)
		do
			flist[++fieldsMin]=0
		while (fieldsMin < NF)
	res=""
	r=""
	for (i=1; i <= NF; i++)
		if (complement == "" ? i in flist : !(i in flist)) {
			if (r)
				res=res OFS
			r="y"
			res=res $i
		}
	if (r)
		print res
	else
		if (only_delimited == "") {
			gsub(FS, OFS)
			print $0
		}
}
