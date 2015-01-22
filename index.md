---
title       : How to Lie with Degree Days
subtitle    : 
author      : David Lindelöf
job         : 
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : [mathjax]            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
---

## The problem

Suppose you invest in a better insulation for your house.
*How then will you know whether your investement was effective?*

Three options:

* Use the [International performance measurement and verification protocol](http://en.wikipedia.org/wiki/International_performance_measurement_and_verification_protocol)
 * requires historic data, takes a very long time to perform
* Measure your energy signature before and after the installation
 * requires simultaneous measurement of outdoor temperatures
* Measure your energy use, and correlate with degree-days in your region
 * very easy to implement, usually the first choice of energy consultants

--- .class #id 

## The danger with degree-days

Degree-days are published by local authorities and are supposedly a reliable indicator of how
much energy a building is going to need to keep its indoor temperature.

The degree-days for a given day are loosely defined as:

$$DD = max(0, t_\text{base} - \overline{t_\text{out}})$$

where $t_\text{base}$ is the so-called *baseline temperature*, i.e. the average outdoor temperature
above which the internal and free gains of a building make extra heating unnecessary, and $\overline{t_\text{out}}$ is the mean outdoor temperature for that day.

Then if a building needs $E$ kWh in a day with $DD$ degree-days, its energy performance will be
given as $\frac{E}{DD}$. The lower this value, the better.

The problem is that $DD$ depends on $t_\text{base}$, which is chosen by the local
authority but should be different from building to building.

--- .class #id

## Example

Your house's real baseline temperature is 20ºC. Degree-days published in your region
assume a baseline temperature of 18ºC. You want to estimate how much energy your house
will need at 0ºC outdoor temperature, before and after installing a new insulation.

Before installing the new insulation, you measure your building's energy consumption during a day
at 100 kWh, with an average outdoor temperature of 10ºC.

After installing it, you measure the energy again for one day and find that you require
25 kWh during a day with 15ºC average outdoor temperature.

So how much energy would your house need at 0ºC, with or without degree-days,
before and after the new insulation?

--- .class #id

## Degree-days prediction


```r
dd.baseline <- 18
true.baseline <- 20
d <- data.frame(Energy=c(100,25), Degrees=c(10,15), System=c("Before", "After"))
d
```

```
##   Energy Degrees System
## 1    100      10 Before
## 2     25      15  After
```


```r
dd.performance <- by(d, d$System, function(x) x$Energy / (dd.baseline - x$Degrees))
as.numeric(dd.performance * dd.baseline)
```

```
## [1] 150 225
```

The degree-days method predicts 225 kWh and 150 kWh consumption at 0ºC, before
and after the new insulation, or an improvement of 33%.

--- .class #id

## True prediction

Here is the prediction when using the building's true baseline:


```r
true.performance <- by(d, d$System, function(x) x$Energy / (true.baseline - x$Degrees))
as.numeric(true.performance * true.baseline)
```

```
## [1] 100 200
```

So in reality, the building will use 200 kWh and 100 kWh at 0ºC, before and after the
new installation, or an improvement of 50%, not merely 33%.

[This Shiny app](https://dlindelof.shinyapps.io/degreedays/) will let you play with different values for the degree-days baseline
and the true baseline, and see how this affects the predicted energy savings with
a set of simulated data.
