package com.milogert.christmas.daos

import com.milogert.christmas.structures.*

class WishlistDao {

    // Create.
    fun createItem(ownerId: Int, text: String, year: Int = com.milogert.christmas.daos.year) {
        transaction {
            return@transaction WishlistItem.new {
                owner = Person[ownerId]
                this.text = text
                this.year = YearConfig.find { YearConfigs.year eq year }.first() // Should only be one.
            }.id.value
        }
    }

    fun claimItem(claimerId: Int, itemId: Int, year: Int) {
        transaction {
            val item = WishlistItem[itemId]
            item.claimed = true
            item.claimedBy = Person[claimerId]
            item.year = YearConfig.find { YearConfigs.year eq year }.first() // Should only be one.
        }
    }

    fun unclaimItem(currentClaimerId: Int, itemId: Int, year: Int = com.milogert.christmas.daos.year) = transaction {
        val item = WishlistItem[itemId]
        val claimedBy = item.claimedBy ?: return@transaction

        if (claimedBy.id.value != currentClaimerId)
            return@transaction

        item.claimed = false
        item.claimedBy = null
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