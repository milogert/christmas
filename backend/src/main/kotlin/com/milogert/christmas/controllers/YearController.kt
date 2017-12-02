package com.milogert.christmas.controllers

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
class YearController {

    @GetMapping("/newYear")
    fun newYear(@RequestParam(value = "year") year: Int) {
        // Add to database.
    }
}