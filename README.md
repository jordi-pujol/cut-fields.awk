# cut-fields.awk
cut utility for fields

Mimics the syntax and behaviour of the coreutils cut utility.
Parameters are passed through variables:
- -v fields=range[,range,...] select only these fields;
  <br>also print any line that contains no delimiter character,
  <br>unless the only_delimited option is specified
- -v FS="regexp" delimiter may be a regular expression, optional,
	<br>if not specified will use the awk default field delimiter
- -v OFS= output delimiter, optional
	<br>if not specified will use the awk default field output delimiter
- -v RS= record delimiter, optional,
	<br>if not specified will use the awk default record delimiter
- -v complement= complement the set of selected fields,
	<br>set to any character to enable
- -v only_delimited= do not print lines not containing delimiters,
	<br>set to any character to enable

Examples:
  ```
  echo "en un lugar de la Mancha de cuyo nombre no quiero acordarme" | \
    ./cut-fields.awk \
	-v fields='-2,4-6,8-' \
	-v FS='[[:blank:],]' \
	-v OFS=","  \
	-v complement=y \
	-v only_delimited=y
  ````
