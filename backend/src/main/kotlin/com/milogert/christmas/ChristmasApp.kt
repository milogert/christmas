package com.milogert.christmas;

import com.milogert.christmas.controllers.k_year
import com.milogert.christmas.daos.name
import com.milogert.christmas.daos.transaction
import com.milogert.christmas.structures.*
import org.jetbrains.exposed.sql.Database
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication

import org.jetbrains.exposed.sql.SchemaUtils.create

/**
 * Main application.
 */
@SpringBootApplication
class ChristmasApp

/**
 * Main function for spring boot.
 */
fun main(args: Array<String>) {
    SpringApplication.run(ChristmasApp::class.java, *args)

    // Run startup db code.
    Database.connect(name, driver = "org.sqlite.JDBC")
    transaction {
        create(People, WishlistItems, YearConfigs, SantaReceivers)

        // Add a new year and a new secret year.
        if (YearConfig.find { YearConfigs.year eq k_year }.count() <= 0) {
            YearConfig.new {
                year = k_year
                isSecret = false
            }
        } else {
            println("Year was found: $k_year")
        }
    }
}