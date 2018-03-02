package com.milogert.christmas.daos

import com.milogert.christmas.structures.*
import org.jetbrains.exposed.sql.and
import java.util.*

class PersonDao() {
    private val wishlistDao = WishlistDao()

    /**
     * Create person.
     *
     * @param person the person to create. This one probably lacks an id.
     * @return a whole person.
     */
    fun createPerson(name: String, email: String) : Person = transaction {
         Person.new {
            this.name = name
            this.email = email
        }
    }

    fun getOrCreatePerson(name: String, email: String): Person {
        // Is person in the database?
        var ret: Person
        try {
            ret = getPersonByName(name)
        } catch (e: Exception)
        {
            e.printStackTrace()
            ret = createPerson(name, email)
        }

        return ret
    }

    // Read.
    fun getPersonByName(name: String, fill: Boolean = true): Person {
        return getPersonById(transaction { Person.find { People.name eq name }.first().id.value }, fill = fill)
    }

    /**
     * Gets a person by id. Optionally fills in the person based on other data.
     */
    fun getPersonById(id: Int, fill: Boolean = true) = transaction {
        val person = Person.get(id)

        if (fill) {
            person.wishlist = wishlistDao.getWishlistByOwnerId(person.id.value)

            // Map the receivers.
            person.receivers = getReceiversBySanta(person.id.value).map { x -> x.render() }

            // Map the claimed items.
            person.claimedItems = wishlistDao.getWishlistByClaimedId(person.id.value)
        }

        return@transaction person
    }

    // Update.
    fun update(oId: Int, name: String, email: String) = transaction {
        val old = Person.get(oId)

        old.name = name
        old.email = email
    }

    fun createReceiver(santaId: Int, receiverId: Int, year: Int) : List<Person> = transaction {
        if (
            SantaReceiver.find {
                (SantaReceivers.santaId eq santaId) and
                (SantaReceivers.receiverId eq receiverId) and
                (SantaReceivers.year eq YearConfig.find { YearConfigs.year eq year }.first().id)
            }.count() <= 0
        ) {
            SantaReceiver.new {
                this.santaId = Person[santaId]
                this.receiverId = Person[receiverId]
                this.year = YearConfig.find { YearConfigs.year eq year }.first() // Should only be one.
            }
        } else
        {
            println("Found santa-reciever pair: $santaId - $receiverId")
        }

        return@transaction Arrays.asList(getPersonById(santaId), getPersonById(receiverId))
    }

    fun getReceiversBySanta(santaId: Int) : Iterable<Person> = transaction {
        SantaReceiver.find { SantaReceivers.santaId eq santaId }.map { x -> x.receiverId }.toList()
    }

    fun getAllPeople(): Iterable<Person> = transaction { Person.all() }
}
