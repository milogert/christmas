package com.milogert.christmas.structures

import com.milogert.christmas.structures.SantaReceivers.reference
import org.jetbrains.exposed.dao.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.div
import org.jetbrains.exposed.sql.Table

/**
 * Table.
 */
object People : IntIdTable() {
    var name = varchar("name", 50).uniqueIndex()
    var email = varchar("email", 200).uniqueIndex()
}

/**
 * Row.
 */
class Person(id: EntityID<Int>) : IntEntity(id) {
    companion object : IntEntityClass<Person>(People)

    var name by People.name
    var email by People.email

    var wishlist: Iterable<WishlistItem> = ArrayList<WishlistItem>()
    var receivers: Iterable<Person.Render> = ArrayList<Person.Render>()
    var claimedItems: Iterable<WishlistItem> = ArrayList<WishlistItem>()

    data class Render(
            val name: String,
            val email: String,
            val wishlist: Iterable<WishlistItem>,
            val receivers: Iterable<Person.Render>,
            val claimedItems: Iterable<WishlistItem>
    )
    fun render() : Person.Render {
        return Person.Render(this.name, this.email, this.wishlist, this.receivers, this.claimedItems)
    }
}

/**
 * Table.
 */
object WishlistItems: IntIdTable() {
    var owner = reference("owner", People)
    var text = varchar("text", 1000)
    var claimed = bool("claimed")
    var claimedBy = reference("claimed_by", People).nullable()
    var year = reference("year", YearConfigs)
}

/**
 * Row.
 */
class WishlistItem(id: EntityID<Int>) : IntEntity(id) {
    companion object : IntEntityClass<WishlistItem>(WishlistItems)

    var owner by Person referencedOn WishlistItems.owner
    var text by WishlistItems.text
    var claimed by WishlistItems.claimed
    var claimedBy by Person optionalReferencedOn WishlistItems.claimedBy
    var year by YearConfig referencedOn WishlistItems.year
}

/**
 * Table.
 */
object YearConfigs : IntIdTable() {
    var year = integer("year")
    var isSecret = bool("is_secret")

    init {
        index(true, year, isSecret)
    }
}

/**
 * Row.
 */
class YearConfig(year: EntityID<Int>) : IntEntity(year) {
    companion object : IntEntityClass<YearConfig>(YearConfigs)

    var year by YearConfigs.year
    var isSecret by YearConfigs.isSecret

    var participants: ArrayList<Int> = ArrayList<Int>()
}

/**
 * Table.
 */
object SantaReceivers : IntIdTable() {
    var santaId = reference("santa_id", People)
    var receiverId = reference("receiver_id", People)
    var year = entityId("year", YearConfigs).references(YearConfigs.id)

    init {
        index(true, santaId, receiverId, year)
    }
}

/**
 * Row.
 */
class SantaReceiver(id: EntityID<Int>) : IntEntity(id) {
    companion object : IntEntityClass<SantaReceiver>(SantaReceivers)

    var santaId by Person referencedOn SantaReceivers.santaId
    var receiverId by Person referencedOn SantaReceivers.receiverId
    var year by YearConfig referencedOn SantaReceivers.year
}





object Users : IntIdTable() {
        val name = varchar("name", 50).index()
        val city = reference("city", Cities)
        val age = integer("age")
}

object Cities: IntIdTable() {
        val name = varchar("name", 50)
}

class User(id: EntityID<Int>) : IntEntity(id) {
        companion object : IntEntityClass<User>(Users)

        var name by Users.name
        var city by City referencedOn Users.city
        var age by Users.age
}

class City(id: EntityID<Int>) : IntEntity(id) {
        companion object : IntEntityClass<City>(Cities)

        var name by Cities.name
        val users by User referrersOn Users.city
}