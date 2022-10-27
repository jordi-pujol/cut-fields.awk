#!/usr/bin/awk -f
##
##	cut-fields - cut utility for fields.
##	Mimics the syntax and behaviour of the coreutils cut utility.
##
##	Examples:
##		echo "en un lugar de la Mancha de cuyo nombre no quiero acordarme" | \
##			./cut-fields.awk \
##				-v fields='-2,4-6,8-' \
##				-v FS='[[:blank:],]' \
##				-v OFS=","  \
##				-v complement=y \
##				-v only_delimited=y
##

function usage(e1)
{
    e1 = "usage: echo \"text\" | cut-fields.awk\
\n\tMimics the syntax and behaviour of the coreutils cut utility.\
\n\tParameters are passed through variables:\
\n\t-v fields= select only these fields;\
\n\talso print any line that contains no delimiter character,\
\n\t	unless the only_delimited option is specified\
\n\t-v FS= delimiter may be a regular expression, optional,\
\n\t	if not specified will use the awk default field delimiter\
\n\t-v OFS= output delimiter, optional\
\n\t	if not specified will use the awk default field output delimiter\
\n\t-v RS= record delimiter, optional,\
\n\t	if not specified will use the awk default record delimiter\
\n\t-v complement= complement the set of selected fields,\
\n\t	set to any character to enable\
\n\t-v only_delimited= do not print lines not containing delimiters,\
\n\t	set to any character to enable"
    print e1 > "/dev/stderr"
    exit 1
}

BEGIN {
	if (! fields)
		usage()
	split(fields, fieldsarray, "[,[:blank:]]+")
}
{
	if (only_delimited && match($0, FS) == 0)
		next
	delete flist
	for (h in fieldsarray) {
		f=fieldsarray[h]
		if (!f) continue
		i=index(f, "-")
		if (i != 0) { # range
			m = split(f, g, "-")
			if (m == 2 && ! g[2])
				m=1
			if (m == 2 && ! g[1])
				m=1
			if (m == 0 || m > 2 || (m == 2 && g[1] >= g[2])) {
				printf("bad character list: %s\n", f) > "/dev/stderr"
				exit 1
			}
			if (m == 2)
				for (j=g[1]; j <= g[2]; j++)
					flist[j] = j
			else
				if (i == 1)
					for (j=1; j <= g[2]; j++)
						flist[j] = j
				else
					if (i == length(f))
						for (j=g[1]; j <= NF; j++)
							flist[j] = j
		} else # single field
			flist[f] = f
	}
	for (i=NF; i>= 1; i--)
		if (complement ? (i in flist) : !(i in flist)) {
			for (j=i; j < NF; j++)
				$j=$(j+1)
			NF--
		}
	print $0
}
END{exit rc+1}
