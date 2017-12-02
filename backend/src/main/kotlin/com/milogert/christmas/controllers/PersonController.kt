package com.milogert.christmas.controllers

import com.milogert.christmas.daos.PersonDao
import com.milogert.christmas.daos.WishlistDao
import com.milogert.christmas.daos.orm
import com.milogert.christmas.structures.Person
import org.springframework.web.bind.annotation.*
import org.springframework.web.servlet.view.RedirectView
import java.util.*

/**
 * Greeting controller which contains mapping.
 */
@RestController
@RequestMapping("/person")
class PersonController {

    val personDao = PersonDao(orm)
    val wishlistDao = WishlistDao(orm)

    val k_year = Calendar.getInstance().get(Calendar.YEAR)

    @GetMapping("/add")
    fun add(
            @RequestParam(value = "name", defaultValue = "") name: String,
            @RequestParam(value = "email", defaultValue = "") email: String
    ) : RedirectView {
        if (name.isEmpty() || email.isEmpty())
        {
            System.out.println("Name is empty. This may fail.");
        }

        var person = personDao.getOrCreatePerson(Person(name = name, email = email))

        return RedirectView("/person/profile/" + person.name)
    }

    @GetMapping("/assign")
    fun assign(
            @RequestParam(value = "santa", defaultValue = "0") santa: Int,
            @RequestParam(value = "receiver", defaultValue = "0") receiver: Int
    ) {
        personDao.createReciever(santa, receiver, year = k_year)
    }

    @GetMapping("/claim")
    fun claim(
            @RequestParam(value = "item", defaultValue = "0") item: Int,
            @RequestParam(value = "santa", defaultValue = "0") santa: Int
    ) {
        wishlistDao.claimItem(item, santa, year = k_year)
    }

    @GetMapping("/all")
    fun all() : List<Person> = personDao.getAllPeople()

    @GetMapping("/profile/{person_name}")
    fun profile(@PathVariable person_name: String) : Person = personDao.getPersonByName(person_name)
}