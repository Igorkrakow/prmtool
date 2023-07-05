
-- Before building exporter execute this sql , replace new lines with , and set in connection.properties 
-- currDraws=8:4,17:4,10:7,18:7,25:13,27:13
SELECT E.IDDGGAME||':'||E.DRAWNUMBER FROM GIS.DGGAMEEVENT E
INNER JOIN GIS.DGGAME G ON G.IDDGGAME=E.IDDGGAME AND G.IDDGGAMEEVENT_CURRENT=E.IDDGGAMEEVENT;

-- ! ! !  bild csv-exporter.jar

--:::::::::::::::::::::::::::::::TXSTORE:::::::::::::::::::::::::::::::
-- copy to one folder on target server TXSTORE_creation.sh, TXSTORE_export_run.sh, csv-exporter.jar
-- to run export you need to have start and end date (also you can add max TX_HEADER_ID from previous run)

sh TXSTORE_export_run.sh "2023-01-01 00:00:00.000000" "2023-01-07 00:00:00.000000" 1929238

--:::::::::::::::::::::::::::::::FAV:::::::::::::::::::::::::::::::
-- copy to one folder on target server FAV_export_run.sh, csv-exporter.jar

sh FAV_export_run.sh