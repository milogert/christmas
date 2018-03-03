package com.milogert.christmas.daos

import com.milogert.christmas.controllers.k_year
import com.milogert.christmas.structures.*

class WishlistDao() {

    // Create.
    fun createItem(ownerId: Int, text: String, year: Int = k_year) {
        transaction {
            return@transaction WishlistItem.new {
                owner = Person.get(ownerId)
                this.text = text
                this.year = YearConfig.find { YearConfigs.year eq year }.first() // Should only be one.
            }.id.value
        }
    }

    fun claimItem(itemId: Int, claimerId: Int, year: Int) {
        transaction {
            val item = WishlistItem.get(itemId)
            item.claimed = true
            item.claimedBy = Person.get(claimerId)
            item.year = YearConfig.find { YearConfigs.year eq year }.first() // Should only be one.
        }
    }

//    // Read.
//    fun getPersonById(id: Int): List<Person> {
//        return db.find(Person(), ninja.sakib.pultusorm.core.PultusORMCondition.Builder().eq("id", id).build()).map { it as Person }
//    }

//    // Update.
//    fun update(old: Person, new: Person) {
//        val condition = Condition.Builder()
//                .eq("id", old.id)
//                .build()
//
//        val updater: PultusORMUpdater = PultusORMUpdater.Builder()
//                .set("name", new.name)
//                .set("email", new.email)
//                .condition(condition)
//                .build()
//        db.update(Person(), updater)
//    }

    fun getWishlistByOwnerId(id: Int): Iterable<WishlistItem> =
            WishlistItem.find { WishlistItems.owner eq id }


    fun getWishlistByClaimedId(id: Int): Iterable<WishlistItem> =
            WishlistItem.find { WishlistItems.claimedBy eq id }
}