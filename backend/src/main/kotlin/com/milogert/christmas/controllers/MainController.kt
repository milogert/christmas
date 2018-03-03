package com.milogert.christmas.controllers

import com.milogert.christmas.structures.Greeting
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController
import java.util.*

val k_year = Calendar.getInstance().get(Calendar.YEAR)

@RestController
class MainController {
    @GetMapping("/")
    fun index() : Greeting {
        return index(k_year)
    }

    @GetMapping("/{year}")
    fun index(@PathVariable year: Int = k_year) : Greeting {
        return Greeting(1, "Hello, $year")
    }
}