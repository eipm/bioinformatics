vcf-concat -p $(ls ${1}/*vcf | egrep -e '(pindel_LI|pindel_RP|pindel_SI|pindel_TD|pindel_INV|pindel_INT_final|pindel_D)') > ${1}/pindel_all.vcf
