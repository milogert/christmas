package com.milogert.christmas.controllers;

import com.milogert.christmas.structures.Greeting
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.concurrent.atomic.AtomicLong

/**
 * Greeting controller which contains mapping.
 */
@RestController
class GreetingController {

    /**
     * The initial counter.
     */
    val counter = AtomicLong()

    /**
     * The current counter. It can have many entries.
     */
    val manycounter = mutableMapOf<String, AtomicLong>();

    /**
     * Greeting mapping.
     *
     * Found at <code>/greeting</code>
     *
     * @param name the name to give the greeting.
     */
    @GetMapping("/greeting")
    fun greeting(@RequestParam(value = "name", defaultValue = "World") name: String) =
            Greeting(manycounter.getOrPut(name, { AtomicLong() }).incrementAndGet(), "Hello, $name")
}