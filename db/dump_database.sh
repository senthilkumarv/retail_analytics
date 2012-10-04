sqlite3 ~/code/retail_analytics/db/dev.sqlite3 <<!
.headers on
.mode csv
.dump $1
!
