package com.milogert.christmas.daos

import org.jetbrains.exposed.sql.Transaction
import org.jetbrains.exposed.sql.transactions.TransactionManager
import java.sql.Connection


val name: String = "jdbc:sqlite:./christmas.db"

fun <T> transaction(statement: Transaction.() -> T): T = org.jetbrains.exposed.sql.transactions.transaction(Connection.TRANSACTION_SERIALIZABLE, 3, statement)