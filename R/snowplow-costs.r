#' Calculate the total Amazon costs associated with running Snowplow X months ahead
#'
#' @param uniquesPerMonth The number of unique visitors to website(s) per month (integer)
#' @param eventsPerMonth The number of events per month tracked (integer)
#' @param runsPerDay The number of times per day that enrichment process is run (generally 1-24) (integer)
#' @param storageDatabase The type of database used to store Snowplow data. This *MUST* either be 'redshift' or 'postgres'
#' @param numberOfMonths number of months ahead that the model should project costs (e.g. 12 or 36)
#' @param edgeLocations The number of different locations in Amazon's Cloudfront network that each generate an independent log when hit. We believe this number is between 10000 and 100000, but are not sure. (This has an impact on S3 costs)
#'
#' @export
snowplowCostByMonth <- function(uniquesPerMonth, eventsPerMonth, runsPerDay, storageDatabase, numberOfMonths, edgeLocations, collector="cloudfront", managedService = TRUE){
	
	month <- seq(1, numberOfMonths, by=1)
	
	# Snowplow cost is made up of Cloudfront, S3, EMR and database (Redshift / storage) costs
  if (collector=="cloudfront") {
	  cloudfrontCost <- cfCostPerMonth(eventsPerMonth, uniquesPerMonth)
  } else {
    cloudfrontCost <- 0
  }
  if (collector=="clojure") {
    ec2Cost <- ec2CostPerMonth(eventsPerMonth)
  } else {
    ec2Cost <- 0
  }
  if (managedService) {
    managed <- 1000
  } else {
    managed <- 0
  }
	s3Cost <- s3CostByMonth(eventsPerMonth, runsPerDay, edgeLocations, numberOfMonths)
	emrCost <- emrCostPerMonth(eventsPerMonth, runsPerDay)
	databaseCost <- databaseCostByMonth(storageDatabase, eventsPerMonth, numberOfMonths)

	# Combine above 4 costs in a single data frame:
	snowplowCost <- data.frame(month, cloudfrontCost, s3Cost, emrCost, databaseCost, ec2Cost, managed)
	snowplowCost$totalCost <- snowplowCost$cloudfrontCost + snowplowCost$s3Cost + snowplowCost$emrCost + snowplowCost$databaseCost + ec2Cost + managed

	# Now return the completed data frame
	snowplowCost
}
