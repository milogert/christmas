package com.milogert.christmas.daos

import com.milogert.christmas.structures.Person
import com.milogert.christmas.structures.WishlistItem
import ninja.sakib.pultusorm.core.PultusORM
import ninja.sakib.pultusorm.core.PultusORMUpdater
import ninja.sakib.pultusorm.core.PultusORMCondition as Condition

class WishlistDao(orm: PultusORM) {
    var db = orm

    // Create.
    fun createItem(wli: WishlistItem) : Int {
        if (db.save(wli)) {
            val condition = Condition.Builder()
                    .eq("owner", wli.owner)
                    .and()
                    .eq("text", wli.text)
                    .build()
            return (db.find(WishlistItem(), condition)[0] as WishlistItem).id
        } else
            return -1
    }

    fun claimItem(wishlistItem: WishlistItem, person: Person, year: Int) {
        claimItem(wishlistItem.id, person.id, year = year)
    }

    fun claimItem(itemId: Int, claimerId: Int, year: Int) {
        val condition = Condition.Builder().eq("id", itemId).build()

        val updater: PultusORMUpdater = PultusORMUpdater.Builder()
                .set("claimedBy", claimerId)
                .set("year", year)
                .condition(condition)
                .build()
        db.update(WishlistItem(), updater)
    }

    // Read.
    fun getPersonById(id: Int): List<Person> {
        return db.find(Person(), ninja.sakib.pultusorm.core.PultusORMCondition.Builder().eq("id", id).build()).map { it as Person }
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

    fun getWishlistByOwnerId(id: Int): List<WishlistItem> =
            db.find(WishlistItem(), Condition.Builder().eq("id", id).build()).map { it as WishlistItem }


    fun getWishlistByClaimedId(id: Int): List<WishlistItem> =
            db.find(WishlistItem(), Condition.Builder().eq("claimedBy", id).build()).map { it as WishlistItem }
}