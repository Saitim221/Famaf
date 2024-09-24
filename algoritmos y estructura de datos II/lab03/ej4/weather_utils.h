#ifndef _WEATHER_UTILS_H
#define _WEATHER_UTILS_H

#include <stdio.h>
#include "weather.h"
#include "array_helpers.h"

int minimun_temperature(WeatherTable array);
//Devuelve la minima temperatura historica

void maximun_temperature( WeatherTable array, int output[] );
//Devuelve maxima temperatura

void months_with_rainfall(WeatherTable a, unsigned int output[]);

#endif
