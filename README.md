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

Each LIST of fields is made up of one range,
or many ranges separated by commas.
<br>Selected input is written in the same order that
it is read, and is written exactly once.
<br>Each range is one of:

- `N`      N'th byte, character or field, counted from 1
- `N-`     from N'th byte, character or field, to end of line
- `N-M`    from N'th to M'th (included) byte, character or field
- `-M`      from first to M'th (included) byte, character or field

Examples:
  ```
  $ echo "en un lugar de la Mancha de cuyo nombre no quiero acordarme" | \
    ./cut-fields.awk \
	-v fields='-2,4-6,8-' \
	-v FS='[[:blank:],]' \
	-v OFS=","  \
	-v complement=y \
	-v only_delimited=y

lugar,de
  ````

  ```
$ ./cut-fields.awk \
	-v fields='1,4-5,8-' \
	-v complement= \
	-v only_delimited= \
	cut-fields-test1.txt; \
	echo $?

en de la
en de la nombre
en de la nombre no quiero acordarme
en de la nombre no quiero acordarme no ha mucho tiempo
en de la nombre no quiero acordarme no ha mucho tiempo que vivía
en de la nombre no quiero acordarme no ha mucho tiempo que vivía un hidalgo
en de la nombre
0
  ````
