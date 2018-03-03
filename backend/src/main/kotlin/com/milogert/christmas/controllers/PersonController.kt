package com.milogert.christmas.controllers

import com.milogert.christmas.daos.PersonDao
import com.milogert.christmas.daos.WishlistDao
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

    val personDao = PersonDao()
    val wishlistDao = WishlistDao()

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

        var person = personDao.getOrCreatePerson(name, email)

        return RedirectView("/person/profile/" + person.id.value)
    }

    @GetMapping("/assign")
    fun assign(
            @RequestParam(value = "santa", defaultValue = "0") santa: Int,
            @RequestParam(value = "receiver", defaultValue = "0") receiver: Int
    ) : Iterable<Person.Render> {
        return personDao.createReceiver(santa, receiver, year = k_year).map { x -> x.render() }.toList()
    }

    @GetMapping("/claim")
    fun claim(
            @RequestParam(value = "item", defaultValue = "0") item: Int,
            @RequestParam(value = "santa", defaultValue = "0") santa: Int
    ) {
        wishlistDao.claimItem(item, santa, year = k_year)
    }

    @GetMapping("/all")
    fun all() : Iterable<Person.Render> = personDao.getAllPeople().map { x -> x.render() }.toList()

    @GetMapping("/profile/{id}")
    fun profile(@PathVariable id: Int) : Person.Render = personDao.getPersonById(id).render()

    @GetMapping("/profiles")
    fun profiles(@PathVariable id: Int) : Person.Render = personDao.getPersonById(id).render()
}