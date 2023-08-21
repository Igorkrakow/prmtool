#!/bin/bash
# The following three lines have been added by UDB DB2.
#to run this file use command: sh FAV-export.sh
# !!! Use current date to export !!!
#set variable
logfile="scriptlog.log"
echo "" | tee -a $logfile
echo "------------ Start FAV export ------------" | tee -a $logfile
log_with_timestamp() {
  local current_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "" | tee -a $logfile
  echo "$current_timestamp - $1" | tee -a $logfile
}
num_rows=100000
fileNameEndDate=$(date -d "$current_timestamp" +%Y%m%d)
db2 connect to pddb
log_with_timestamp "CREATE favorite-group_ files"
#####################
echo "---------------------------"
echo "favorite-group"
echo "---------------------------"
db2 export to favorite-group_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'iddgfavoritewagergroup',
        'iddgfavoritewagergroupnumber',
        'iddgfavoritewagergroupname',
        'playerid'
    FROM sysibm.sysdummy1"
db2 export to favorite-group_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
    select IDDGFAVORITEWAGERGROUP,
        IDDGFAVORITEWAGERGROUPNUMBER,
        IDDGFAVORITEWAGERGROUPNAME,
        PLAYERID
    from GIS.DGFAVORITEWAGERGROUP"
###########################
db2 terminate
###########################
###########################
csvFileName="favorite-group"
###########################
split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_'
for file in favorite-group_unix-*
do
mv "$file" "$file.csv"
done
count=$(wc -l < $csvFileName'_TMP.csv')
if (($count==0)); then
  mv $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_001.csv'
else
  rm $csvFileName'_TMP.csv'
fi
for f in $csvFileName'_unix-'*
      do
              head -n 1 $csvFileName'_HEADER.csv' > $csvFileName'_HEADER_TMP.csv'
              cat "$f" >>$csvFileName'_HEADER_TMP.csv'
              mv -f $csvFileName'_HEADER_TMP.csv' "$f"
              perl -p -e 's/\n/\r\n/' < $f > ${f//_unix/}
              rm $f
      done
rm $csvFileName'_HEADER.csv'

echo "---------------------------"
echo "favorite-board"
echo "---------------------------"
db2 connect to pddb
log_with_timestamp "CREATE favorite-board_ files"
db2 export to favorite-board_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'board_id',
        'stack_id',
        'stake',
        'system_id',
        'primary_qp',
        'secondary_qp',
        'primary_selections',
        'secondary_selections',
        'tertiary_selections',
        'addon_selection',
        'board_index',
        'modifier'
    FROM sysibm.sysdummy1"
db2 export to favorite-board_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
                                 IDDGFAVORITEBOARD,
                                 IDDGFAVORITEBOARDSTACK,
                                 BOARDSTAKE,
                                 PICKSYSTEM,
                                 CASE WHEN LOCATE(':', PICKVALUES) > 0 THEN
                                                  LENGTH(SUBSTR(PICKVALUES, 1, LOCATE(':', PICKVALUES) - 1)) - LENGTH(REPLACE(SUBSTR(PICKVALUES, 1, LOCATE(':', PICKVALUES) - 1), ',', '')) + 1
                                      ELSE
                                                  LENGTH(PICKVALUES) - LENGTH(REPLACE(PICKVALUES, ',', '')) + 1
                                     END AS primary_qp,
                                 CASE WHEN LOCATE(':', PICKVALUES) > 0 THEN
                                                  LENGTH(SUBSTR(PICKVALUES, LOCATE(':', PICKVALUES) + 1)) - LENGTH(REPLACE(SUBSTR(PICKVALUES, LOCATE(':', PICKVALUES) + 1), ',', '')) + 1
                                      ELSE
                                          NULL
                                     END AS secondary_qp,

                                 CASE WHEN LOCATE(':', PICKVALUES) > 0 THEN
                                          '\"'||SUBSTR(PICKVALUES, 1, LOCATE(':', PICKVALUES) - 1)||'\"'
                                      ELSE
                                          case when PICKVALUES is null then
                                                   PICKVALUES
                                          else '\"'||PICKVALUES||'\"'
                                          end
                                     END AS primary_selections,
                                 CASE WHEN LOCATE(':', PICKVALUES) > 0 THEN
                                              '\"'||SUBSTR(PICKVALUES, LOCATE(':', PICKVALUES) + 1)||'\"'
                                      ELSE
                                          NULL
                                     END AS secondary_selections,
                                 null as tertiary_selections,
                                 null as addon_selection,
                                 BOARDINDEX,
                                 MODIFIER
                             FROM GIS.DGFAVORITEBOARD"
###########################
db2 terminate
###########################
###########################
csvFileName="favorite-board"
###########################
split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_'
for file in favorite-board_unix-*
do
mv "$file" "$file.csv"
done
count=$(wc -l < $csvFileName'_TMP.csv')
if (($count==0)); then
  mv $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_001.csv'
else
  rm $csvFileName'_TMP.csv'
fi
for f in $csvFileName'_unix-'*
      do
              head -n 1 $csvFileName'_HEADER.csv' > $csvFileName'_HEADER_TMP.csv'
              cat "$f" >>$csvFileName'_HEADER_TMP.csv'
              mv -f $csvFileName'_HEADER_TMP.csv' "$f"
              perl -p -e 's/\n/\r\n/' < $f > ${f//_unix/}
              rm $f
      done
rm $csvFileName'_HEADER.csv'

echo "---------------------------"
echo "favorite-wager"
echo "---------------------------"
db2 connect to pddb
log_with_timestamp "CREATE favorite-wager files"
db2 export to favorite-wager_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'favorite_id',
        'favorite_number',
        'duration',
        'game_id',
        'player_id',
        'price',
        'stake',
        'name',
        'created_ts',
        'modified_ts',
        'favorite_group_id',
        'overtimeplayed'
    FROM sysibm.sysdummy1"
db2 export to favorite-wager_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT IDDGFAVORITEWAGER as favorite_id,
           ROW_NUMBER() OVER (PARTITION BY PLAYERID ORDER BY IDDGFAVORITEWAGER ) AS IDDGFAVORITEWAGERNUMBER,
           NUMBEROFDRAWS as duration,
           IDDGGAME as game_id,
           PLAYERID as player_id,
           TOTALPRICE as price,
           stake as stake,
           NULL as NAME,
           TSCREATED as created_ts,
           TSLASTMODIFIED as modified_ts,
           IDDGFAVORITEWAGERGROUP as favorite_group_id,
           'false' as OVERTIMEPLAYED -- new implementation
    FROM GIS.DGFAVORITEWAGER
    "
###########################
db2 terminate
###########################
###########################
csvFileName="favorite-wager"
###########################
split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_'
for file in favorite-wager_unix-*
do
mv "$file" "$file.csv"
done
count=$(wc -l < $csvFileName'_TMP.csv')
if (($count==0)); then
  mv $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_001.csv'
else
  rm $csvFileName'_TMP.csv'
fi
for f in $csvFileName'_unix-'*
      do
              head -n 1 $csvFileName'_HEADER.csv' > $csvFileName'_HEADER_TMP.csv'
              cat "$f" >>$csvFileName'_HEADER_TMP.csv'
              mv -f $csvFileName'_HEADER_TMP.csv' "$f"
              perl -p -e 's/\n/\r\n/' < $f > ${f//_unix/}
              rm $f
      done
rm $csvFileName'_HEADER.csv'


echo "---------------------------"
echo "favorite-stack"
echo "---------------------------"
db2 connect to pddb
log_with_timestamp "CREATE favorite-stack files"
db2 export to favorite-stack_HEADER.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        'favorite_id',
        'stack_id',
        'game_id',
        'draw_names',
        'addon_stake',
        'is_addon'
    FROM sysibm.sysdummy1"
db2 export to favorite-stack_TMP.csv OF DEL MODIFIED BY NOCHARDEL  "
    SELECT
        IDDGFAVORITEWAGER favorite_id,
        IDDGFAVORITEBOARDSTACK stack_id,
        IDDGGAME as game_id,
        NULL as draw_names,
        NULL as addon_stake,
        'false' as is_addon
    FROM GIS.DGFAVORITEBOARDSTACK"
###########################
db2 terminate
###########################
###########################
csvFileName="favorite-stack"
###########################
split --numeric-suffixes --suffix-length=3  -l $num_rows $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_'
for file in favorite-stack_unix-*
do
mv "$file" "$file.csv"
done
count=$(wc -l < $csvFileName'_TMP.csv')
if (($count==0)); then
  mv $csvFileName'_TMP.csv' $csvFileName'_unix-'$fileNameEndDate'_001.csv'
else
  rm $csvFileName'_TMP.csv'
fi
for f in $csvFileName'_unix-'*
      do
              head -n 1 $csvFileName'_HEADER.csv' > $csvFileName'_HEADER_TMP.csv'
              cat "$f" >>$csvFileName'_HEADER_TMP.csv'
              mv -f $csvFileName'_HEADER_TMP.csv' "$f"
              perl -p -e 's/\n/\r\n/' < $f > ${f//_unix/}
              rm $f
      done
rm $csvFileName'_HEADER.csv'
sh SQL/kpi.sh
echo "" | tee -a $logfile
echo "------------ END export ------------" | tee -a $logfile