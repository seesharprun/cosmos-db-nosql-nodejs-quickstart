metadata description = 'Create database account resources.'

param databaseAccountName string
param tags object = {}

var database = {
  name: 'cosmicworks' // Based on AdventureWorksLT data set
}

var containers = [
  {
    name: 'products' // Set of products
    partitionKeyPaths: [
      '/category' // Partition on the product category
    ]
    autoscale: true // Scale at the container level
    throughput: 1000 // Enable autoscale with a minimum of 100 RUs and a maximum of 1,000 RUs
  }
]

module cosmosDbDatabase '../core/database/cosmos-db/nosql/database.bicep' = {
  name: 'cosmos-db-database-${database.name}'
  params: {
    name: database.name
    parentAccountName: databaseAccountName
    tags: tags
    setThroughput: false
  }
}

module cosmosDbContainers '../core/database/cosmos-db/nosql/container.bicep' = [for (container, _) in containers: {
  name: 'cosmos-db-container-${container.name}'
  params: {
    name: container.name
    parentAccountName: databaseAccountName
    parentDatabaseName: cosmosDbDatabase.outputs.name
    tags: tags
    setThroughput: true
    autoscale: container.autoscale
    throughput: container.throughput
    partitionKeyPaths: container.partitionKeyPaths
  }
}]

output database object = {
  name: cosmosDbDatabase.outputs.name
}
output containers array = [for (_, index) in containers: {
  name: cosmosDbContainers[index].outputs.name
}]
