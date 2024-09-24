#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h> 

#include "weather.h"
#include "weather_utils.h"

int minimun_temperature(WeatherTable array){
    int min = INT_MAX;
    for (unsigned int year = 0; year < LST_YEAR - FST_YEAR; year++){
        for(unsigned int month = 0; month < MONTHS - 1; month++){
            for(unsigned int day = 0; day < LST_DAY - FST_DAY; day++){
                min = minimun(array[year][month][day]._min_temp, min);
            }
        }
        
    }
    return min;
}

void maximun_temperature( WeatherTable array, int output[] ){



    for(unsigned int year = 0; year < YEARS; year++){
        int max = INT_MIN;

       for(unsigned int month = 0; month < MONTHS - 1; month++){
            for(unsigned int day = 0; day < LST_DAY - FST_DAY; day++){
                max = maxi(max, array[year][month][day]._max_temp);
            }
        }


        output[year] = max;
    }
}

void months_with_rainfall(WeatherTable a, unsigned int output[]){
    for (unsigned int year = 0; year < YEARS; year++) {
        unsigned int maximum_of_each_day = 0; 
        unsigned int maximum_of_each_month = 0;
        for(unsigned int month = 1; month <= MONTHS; month ++){
            for(unsigned int day = 0; day < DAYS; day++){
               
                if(a[year][month][day]._rainfall >= maximum_of_each_day){
                    maximum_of_each_day = a[year][month][day]._rainfall;
                }
            }
            
            if(maximum_of_each_day > maximum_of_each_month){
                maximum_of_each_month = maximum_of_each_day;
                output[year] = month;
            }
        }
    }
}