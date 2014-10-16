# Calculate the EC2 cost per month, based on the number of uniques and number of events per month

# Assumptions:
# * 10M requests can be served by 1 m3.medium instance
# * using pricing at http://aws.amazon.com/ec2/pricing/
# * all requests served to users in the US
ec2CostPerMonth <- function(events){
  eventsProcessableByM3MediumInstance <- 10000000
  nodes <- ceiling(events / eventsProcessableByM3MediumInstance)
  hoursPerMonth <- 24*365.25/12
  costOfM3Instance <- 0.098
	nodes * hoursPerMonth * costOfM3Instance
}

