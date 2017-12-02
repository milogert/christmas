package com.milogert.christmas.daos

import com.milogert.christmas.structures.Person
import com.milogert.christmas.structures.SantaReceiver
import ninja.sakib.pultusorm.core.PultusORM
import ninja.sakib.pultusorm.core.PultusORMUpdater
import ninja.sakib.pultusorm.core.PultusORMCondition as Condition

class PersonDao(orm: PultusORM) {
    var db = orm

    /**
     * Create person.
     *
     * @param person the person to create. This one probably lacks an id.
     * @return a whole person.
     */
    fun createPerson(person: Person) : Person {
        if (db.save(person)) {
            return getPersonByName(person.name)
        } else
            return Person()
    }

    fun getOrCreatePerson(person: Person): Person {
        // Is person in the database?
        var ret: Person
        try {
            ret = getPersonByName(person.name)
        } catch (e: Exception)
        {
            e.printStackTrace()
            ret = createPerson(person)
            ret.new = true
        }

        return ret
    }

    // Read.
    fun getPersonByName(name: String, fill: Boolean = true): Person {
        return getPersonById((db.find(Person(), Condition.Builder().eq("name", name).build()).single() as Person).id)
    }

    fun getPersonById(id: Int, fill: Boolean = true): Person {
        val person = db.find(Person(), Condition.Builder().eq("id", id).build()).single() as Person

        if (fill) {
            // Map the wishlist items.
            val wishlistDao = WishlistDao(db)
            person.wishlist = wishlistDao.getWishlistByOwnerId(person.id)

            // Map the receivers.
            person.receivers = getReceiversBySanta(person.id)

            // Map the claimed items.
            person.claimedItems = wishlistDao.getWishlistByClaimedId(person.id)
        }

        return person
    }

    // Update.
    fun update(old: Person, new: Person) {
        val condition = Condition.Builder()
                .eq("id", old.id)
                .build()

        val updater: PultusORMUpdater = PultusORMUpdater.Builder()
                .set("name", new.name)
                .set("email", new.email)
                .condition(condition)
                .build()
        db.update(Person(), updater)
    }

    fun createReciever(santaId: Int, receiverId: Int, year: Int) {
        db.save(SantaReceiver(santaId, receiverId, year = year))
    }

    fun getReceiversBySanta(id: Int) : List<Person> {
        val condition = Condition.Builder().eq("santaId", id).build()

        val srMap = db.find(SantaReceiver(), condition).map { it as SantaReceiver }

        if (srMap.isEmpty())
        {
            return ArrayList<Person>()
        }

        var personCondition = Condition.Builder()

        for (it in srMap) {
            personCondition = personCondition.eq("id", it.receiverId)
            if (!srMap.last().equals(it))
                personCondition = personCondition.or()
        }

        val builtCondition = personCondition.build()
        return db.find(Person(), builtCondition).map { it as Person }
    }

    fun getAllPeople(): List<Person> {
        return db.find(Person()).map { it as Person }
    }
}