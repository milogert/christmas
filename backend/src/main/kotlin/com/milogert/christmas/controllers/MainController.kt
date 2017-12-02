package com.milogert.christmas.controllers

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController
import java.util.*

val k_year = Calendar.getInstance().get(Calendar.YEAR)

@RestController
class MainController {
    @GetMapping("/{year}")
    fun index(@PathVariable year: Int = k_year) {
        // Get all users
    }
}