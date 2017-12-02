package com.milogert.christmas.structures

import ninja.sakib.pultusorm.annotations.AutoIncrement
import ninja.sakib.pultusorm.annotations.Ignore
import ninja.sakib.pultusorm.annotations.PrimaryKey

data class Person(
        @PrimaryKey
        @AutoIncrement
        var id: Int = -1,

        val name: String = "",
        val email: String = "",

        @Ignore var wishlist: List<WishlistItem> = ArrayList<WishlistItem>(),
        @Ignore var receivers: List<Person> = ArrayList<Person>(),
        @Ignore var claimedItems: List<WishlistItem> = ArrayList<WishlistItem>(),
        @Ignore var new: Boolean = false
)