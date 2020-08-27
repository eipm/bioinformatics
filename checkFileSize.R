args = commandArgs(trailingOnly=TRUE)
# test if there is are 2 arguments: if not, return an error and the actual usage
if (length(args)!=2) {
          stop("Usage: Rscript checkFileSize.R <root_folder> <json_file>.\nThe json file should list all the info of the bucket: aws s3api list-objects-v2 --bucket <bucket> --prefix
 <prefix> --endpoint-url <endpoint-url> > <json_file>", call.=FALSE)
} else if (length(args)==2) {
          # default output file
        print(args[1])
        INPUT_DIR=args[1]
        if ( ! dir.exists(INPUT_DIR) ) stop("Directory doesn't exists: ", INPUT_DIR)
        JSON_LIST=args[2]
        if ( ! file.exists(JSON_LIST) ) stop("JSON file doesn't exists: ", JSON_LIST)
}

library(jsonlite)

fileSz = fromJSON(JSON_LIST)
fileSz$Contents$fileName = basename(fileSz$Contents$Key)
print("------- START -----")
for ( f in list.files(INPUT_DIR, include.dirs = FALSE, recursive=TRUE, all.files=FALSE, full.name=TRUE ) ) {
        # print(sprintf("Disk file: %s", f))
        sz.disk = file.info(f)$size; 
        sz.aws=fileSz$Contents[ fileSz$Contents$fileName==basename(f),"Size"];
        if( !is.null(sz.aws) ) {
                if( sz.aws != sz.disk ) stop("FAIL: Different size: ", f)
                print(sprintf("OK: Disk: %.0f -- AWS: %.0f -- file: %s", sz.disk, sz.aws, basename(f)));
        } else {
        print("###### Couldn't find ", basename(f))
        }
}
print("------- END -----")
