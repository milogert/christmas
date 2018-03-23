package com.milogert.christmas.daos

import com.milogert.christmas.structures.*
import org.jetbrains.exposed.sql.and
import java.util.*

class PersonDao {
    private val wishlistDao = WishlistDao()

    fun getOrCreatePerson(name: String, email: String): Person =
        try {
            getPersonByName(name)
        } catch (e: Exception)
        {
            createPerson(name, email)
        }

    /**
     * Create person.
     */
    private fun createPerson(name: String, email: String) : Person = transaction {
        Person.new {
            this.name = name
            this.email = email
        }
    }

    // Read.
    private fun getPersonByName(name: String, fill: Boolean = true, me: Boolean = false) : Person =
        getPersonById(transaction { Person.find { People.name eq name }.first().id.value }, fill = fill, me = me)

    /**
     * Gets a person by id. Optionally fills in the person based on other data.
     */
    fun getPersonById(id: Int, fill: Boolean = true, me: Boolean = false) : Person = transaction {
        val person : Person

        try {
            person = Person[id]
        } catch (e : IllegalStateException) {
            println("Could not find $id in the database")
            throw e
        }

        if (fill) {
            fill(person, me = me)
        }

        return@transaction person
    }

    fun fill(person: Person, me: Boolean = false) : Person = transaction {
        person.wishlist = wishlistDao.getWishlistByOwnerId(person.id.value).map(WishlistItem::render)

        // Map the receivers.
        person.receivers = getReceiversBySanta(person.id.value).map(Person::render)

        // Map the claimed items.
        if (me) {
            person.claimedItems = wishlistDao.getWishlistByClaimedId(person.id.value).map(WishlistItem::render)
        }

        return@transaction person
    }

    // Update.
    fun update(id: Int, name: String?, email: String?) : Person.Render = transaction {
        val old = Person[id]

        old.name = name ?: old.name
        old.email = email ?: old.email

        return@transaction old.render()
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
            println("Found santa-receiver pair: $santaId - $receiverId")
        }

        return@transaction Arrays.asList(getPersonById(santaId), getPersonById(receiverId))
    }

    fun getAssigned(santaId: Int) : List<Map<String, Any>> = transaction {
        val assignedIds = SantaReceiver
                .find { SantaReceivers.santaId eq santaId }
                .map { mapOf("name" to Person[it.receiverId.id].name + " (assigned)", "id" to it.receiverId.id.value) }
                .toList()
        assignedIds + Person
                .find { People.id notInList assignedIds.map { it["id"] }.toList() + listOf(santaId) }
                .map { mapOf("name" to it.name, "id" to it.id.value) }
                .toList()
    }

    private fun getReceiversBySanta(santaId: Int) : Iterable<Person> = transaction {
        SantaReceiver.find { SantaReceivers.santaId eq santaId }.map { x -> x.receiverId }.toList()
    }

    fun getAllPeople(): Iterable<Person> = transaction { return@transaction Person.all() }
}
