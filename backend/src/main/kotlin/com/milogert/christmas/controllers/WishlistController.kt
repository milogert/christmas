package com.milogert.christmas.controllers

import com.milogert.christmas.daos.PersonDao
import com.milogert.christmas.daos.WishlistDao
import com.milogert.christmas.structures.Person
import org.springframework.web.bind.annotation.*
import org.springframework.web.servlet.view.RedirectView
import java.util.*

const val ep_wishlist = "/wishlist"
const val ep_wishlist_add = "/add"
const val ep_wishlist_claim = "/claim"
const val ep_wishlist_unclaim = "/unclaim"

/**
 * Greeting controller which contains mapping.
 */
@RestController
@RequestMapping(ep_wishlist)
class WishlistController {

    val personDao = PersonDao()
    val wishlistDao = WishlistDao()

    val k_year = Calendar.getInstance().get(Calendar.YEAR)

    @GetMapping(ep_wishlist_add)
    fun add(
            @RequestParam(value = "id", defaultValue = "0") id: Int,
            @RequestParam(value = "text", defaultValue = "") text: String,
            @RequestParam(value = "year", defaultValue = "0") year: Int
    ) : RedirectView {
        var year_ = year
        if (year_ == 0)
            year_ = k_year

        var wishlistItem = wishlistDao.createItem(id, text, year = year_)

        return RedirectView("/person/profile/" + id)
    }

    @GetMapping(ep_wishlist_claim)
    fun claim(
            @RequestParam(value = "santaId", defaultValue = "0") santaId: Int,
            @RequestParam(value = "wishlistItem", defaultValue = "0") wishlistItem: Int
    ) : RedirectView {
        wishlistDao.claimItem(santaId, wishlistItem, year = k_year)

        return RedirectView("$ep_person$ep_person_profile/$santaId")
    }

    @GetMapping(ep_wishlist_unclaim)
    fun unclaim(
            @RequestParam(value = "santaId", defaultValue = "0") santaId: Int,
            @RequestParam(value = "wishlistItem", defaultValue = "0") wishlistItem: Int
    ) : RedirectView {
        wishlistDao.unclaimItem(santaId, wishlistItem, year = k_year)

        return RedirectView("$ep_person$ep_person_profile/$santaId")
    }
}