output "client_key" {
  value = "${module.aks.client_key}"
}

output "client_certificate" {
  value = "${module.aks.client_certificate}"
}

output "cluster_ca_certificate" {
  value = "${module.aks.cluster_ca_certificate}"
}

output "host" {
  value = "${module.aks.host}"
}

output "username" {
  value = "${module.aks.username}"
}

output "password" {
  value = "${module.aks.password}"
}

output "node_resource_group" {
  value = "${module.aks.node_resource_group}"
}

output "location" {
  value = "${module.aks.location}"
}

output "database_name" {
  description = "Database name of the Azure SQL Database created."
  value       = "${module.sql-database.database_name}"
}

output "sql_server_name" {
  description = "Server name of the Azure SQL Database created."
  value       = "${module.sql-database.sql_server_name}"
}

output "sql_server_location" {
  description = "Location of the Azure SQL Database created."
  value       = "${module.sql-database.sql_server_location}"
}

output "sql_server_version" {
  description = "Version the Azure SQL Database created."
  value       = "${module.sql-database.sql_server_version}"
}

output "sql_server_fqdn" {
  description = "Fully Qualified Domain Name (FQDN) of the Azure SQL Database created."
  value       = "${module.sql-database.sql_server_fqdn}"
}

output "connection_string" {
  description = "Connection string for the Azure SQL Database created."
  value       = "${module.sql-database.connection_string}"
}
