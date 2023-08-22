--:::::::::::::::::::::::::::::::TXSTORE:::::::::::::::::::::::::::::::
-- copy to one folder on target server TXSTORE_creation.sh, TXSTORE_export_run.sh, csv-exporter.jar
-- to run export you need to have start and end date (also you can add max TX_HEADER_ID from previous run)

sh TXSTORE_export_run.sh "sql" "KY"("RI") "2022-08-22 00:00:00.000000" "2022-09-01 00:00:00.000000" 1929238

--:::::::::::::::::::::::::::::::FAVORITES:::::::::::::::::::::::::::::::
-- copy to one folder on target server FAV_export_run.sh, csv-exporter.jar

sh FAV_export_run.sh