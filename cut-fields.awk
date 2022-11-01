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
	e1 = "usage: echo \"text\" | cut-fields.awk" \
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

BEGIN {
	if (! fields)
		usage()
	gsub("^[,[:blank:]]+|[,[:blank:]]+$", "", fields)
	split(fields, fieldsarray, "[,[:blank:]]+")
	if (length(fieldsarray) == 0)
		usage()
	fieldsMin=""
	flistSet=""
}
{
	record=$0
	if (! flistSet) {
		flistSet="y"
		for (h in fieldsarray) {
			f=fieldsarray[h]
			if (f == "")
				continue
			m = split(f, g, "-")
			if (m == 0 || m > 2 \
			|| (! g[1] && ! g[2]) \
			|| (g[1] && (g[1] !~ "^[[:digit:]]+$" || g[1] <= 0)) \
			|| (g[2] && (g[2] !~ "^[[:digit:]]+$" || g[2] <= 0)) \
			|| (g[1] && g[2] && g[1] > g[2]) ) {
				printf("bad field range: %s\n", f) > "/dev/stderr"
				exit 1
			}
			if (g[1] && g[2])
				for (i=g[1]; i <= g[2]; i++)
					flist[i]=0
			else
				if (g[2])
					for (i=1; i <= g[2]; i++)
						flist[i]=0
				else
					if (m == 2) {
						for (i=g[1]; i <= NF; i++)
							flist[i]=0
						fieldsMin= g[1] >= NF ? g[1] : NF
					} else
						flist[g[1]]=0
		}
		if (length(flist) == 0)
			usage()
	}
	if (fieldsMin && fieldsMin < NF)
		do
			flist[++fieldsMin]=0
		while (fieldsMin < NF)
	for (i=NF; i>= 1; i--)
		if (complement ? (i in flist) : !(i in flist)) {
			for (j=i; j < NF; j++)
				$j=$(j+1)
			NF--
		}
	if ($0)
		print $0
	else
		if (! only_delimited)
			print record
}
