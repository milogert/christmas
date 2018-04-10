package com.milogert.christmas.daos

import com.milogert.christmas.structures.Person
import java.util.*

class GeneralDao {

    val personDao = PersonDao()

    fun pair() = transaction {
        // Get people.
        val peopleIds = Person.all()

        // Duplicate list.
        val peopleCopy = peopleIds.toMutableList().shuffle()

        // Add to database.
        peopleIds.zip(peopleCopy).map {
            personDao.createReceiver(it.first.id.value, it.second.id.value, year = year)
        }
    }

    /**
     * Shuffle a list.
     *
     * Thanks to: https://www.samclarke.com/kotlin-shuffle-arrays-and-lists/
     */
    fun <T, L : MutableList<T>> L.shuffle(): L {
        val rng = Random()

        for (index in 0..this.size - 1) {
            val randomIndex = rng.nextInt(this.size)

            // Swap with the random position
            val temp = this[index]
            this[index] = this[randomIndex]
            this[randomIndex] = temp
        }

        return this
    }
}
