DOI=$1
FOIS=( $(ls $DOI/*vcf | egrep -e '(pindel_LI|pindel_RP|pindel_SI|pindel_TD|pindel_INV|pindel_INT_final|pindel_D)') )
FINAL_FILE=$DOI"/pindel_all.vcf"
VCFS_STR=for i in "${FOIS[*]}"; do echo "$i"; done
vcf-concat -p $VCFS_STR >  $FINAL_FILE
