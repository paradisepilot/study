
#dateString=`date +%Y-%m-%d.%H-%M-%S`
dateString=`date +%Y-%m-%d`

R --no-save < ../code/rebalance-portfolio.R > stdout.R.rebalance-portfolio.$dateString

