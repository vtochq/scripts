#!/bin/bash
#
# Splitting media files by CUE sheet description. Preserve tags and file names. Checking size of splitted files.
# (c) Alexander Kolesnikov (vtochq@gmail.com), 2018
#

if [ -z "$1" ]; then
	echo "Usage: cuesplit.sh <path to media file (flac, ape, wav, ..)>"
	echo "Dependencies: shnsplit cuetag.sh metaflac"
	echo -e "May be used recursively:\n\$ find <path to dir> -type f -name *.flac -size +150M -exec ./cuesplit.sh "{}" \;\nIt will try to split all flac files greater than 150MB."
	exit
fi

if [ ! -f "$1" ]; then
	echo "File not found."
	exit
fi

filename=$(basename -- "$1")
ext="${filename##*.}"
dir=$(dirname "$1")
cue=$(echo "$1" | cut -f 1 -d '.').cue


if [ ! -f "$cue" ]; then
        echo "CUE file not found. ($1)"
        cue=$(ls "$dir"/*.cue 2>/dev/null | head -1)
	if [ -f "$cue" ]; then
		echo "Trying first cue file in dir: $cue"
	else
		exit
	fi
fi


echo "Splitting $1 file"

#Splitting
shnsplit -o $ext -d "$dir" -f "$cue" "$1"

#Tagging
cuetag.sh "$cue" "$dir"/split-*.$ext

# Renaming
for a in "$dir"/split-*.$ext; do
	TITLE=`metaflac "$a" --show-tag=TITLE | sed s/.*=//g`
	TRACKNUMBER=`metaflac "$a" --show-tag=TRACKNUMBER | sed s/.*=//g`
	filename="`printf %02g $TRACKNUMBER`. $TITLE.$ext"
	filename=${filename//[- \\\/]/_}
	mv "$a" "$dir/$filename";
	filenames="$dir/$filename\0$filenames"
done

# Validating size
infile_size=$(stat --printf="%s" "$1")
outfiles_size=$(echo -e -n "$filenames" | du -cb --files0-from=- | grep total | cut -f1) 

if (( outfiles_size > infile_size )); then
	echo -e "Out files size greater than input file. Assume all is OK.\nRenaming input file to $ext.bak\nRenaming CUE to CUE.bak"
	mv "$1" "$1".bak
	mv "$cue" "$cue".bak
else
	echo -e "File size mismatch. Please, manually check output files.\nInput file size:   $infile_size\nOutput files size: $outfiles_size"
fi
