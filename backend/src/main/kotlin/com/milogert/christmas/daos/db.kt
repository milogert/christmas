package com.milogert.christmas.daos

import org.jetbrains.exposed.sql.CompositeSqlLogger
import org.jetbrains.exposed.sql.StdOutSqlLogger
import org.jetbrains.exposed.sql.Transaction
import java.sql.Connection
import java.util.*


val year = Calendar.getInstance().get(Calendar.YEAR)

val name: String = "jdbc:sqlite:./christmas.db"

val logger = CompositeSqlLogger()

fun <T> transaction(statement: Transaction.() -> T): T {
    logger.addLogger(StdOutSqlLogger)
    return org.jetbrains.exposed.sql.transactions.transaction(
            Connection.TRANSACTION_SERIALIZABLE,
            3,
            statement
    )
}