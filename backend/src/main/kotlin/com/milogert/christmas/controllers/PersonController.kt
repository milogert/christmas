package com.milogert.christmas.controllers

import com.milogert.christmas.daos.PersonDao
import com.milogert.christmas.daos.year
import com.milogert.christmas.structures.Person
import org.springframework.web.bind.annotation.*
import org.springframework.web.servlet.view.RedirectView

const val ep_person = "/person"
const val ep_person_add = "/add"
const val ep_person_update = "/update"
const val ep_person_assign = "/assign"
const val ep_person_profile = "/profile"
const val ep_person_profile_id = "$ep_person_profile/{id}"

/**
 * Greeting controller which contains mapping.
 */
@RestController
@RequestMapping(ep_person)
class PersonController {

    val personDao = PersonDao()

    @GetMapping(ep_person_add)
    fun add(
            @RequestParam(value = "name", defaultValue = "") name: String,
            @RequestParam(value = "email", defaultValue = "") email: String
    ) : RedirectView {
        if (name.isEmpty() || email.isEmpty())
        {
            System.out.println("Name is empty. This may fail.")
        }

        val person = personDao.getOrCreatePerson(name, email)

        return RedirectView("$ep_person$ep_person_profile/${person.id.value}")
    }

    @GetMapping(ep_person_update)
    fun update(
            @RequestParam(value = "id") id: Int,
            @RequestParam(value = "name") name: String?,
            @RequestParam(value = "email") email: String?
    ) : RedirectView {
        val person = personDao.update(id, name, email)

        return RedirectView("$ep_person$ep_person_profile/${person.id}")
    }

    @GetMapping(ep_person_assign)
    fun assign(
            @RequestParam(value = "santa", defaultValue = "0") santa: Int,
            @RequestParam(value = "receiver", defaultValue = "0") receiver: Int
    ) : Iterable<Person.Render> {
        return personDao.createReceiver(santa, receiver, year = year).map(Person::render).toList()
    }

    // TODO: Not working.
    @GetMapping(ep_person_profile)
    fun all() : Iterable<Person.Render> = personDao.getAllPeople().map(Person::render).toList()

    @GetMapping(ep_person_profile_id)
    fun profile(
            @PathVariable id: Int,
            @RequestParam(value = "fill", defaultValue = "true") fill: Boolean
    ) : Person.Render =
            personDao.getPersonById(id, fill = fill).render()
}