package com.milogert.christmas.structures

import ninja.sakib.pultusorm.annotations.AutoIncrement
import ninja.sakib.pultusorm.annotations.Ignore
import ninja.sakib.pultusorm.annotations.PrimaryKey

data class WishlistItem(
        @PrimaryKey
        @AutoIncrement
        val id: Int = -1,

        var owner: Int = -1,
        val text: String = "",
        val claimed: Boolean = false,
        val claimedBy: Int = -1,
        val year: Int = -1,

        // Objects for processing later.
        @Ignore val ownerPerson: Person = Person(),
        @Ignore val claimedByPerson: Person = Person()
)
