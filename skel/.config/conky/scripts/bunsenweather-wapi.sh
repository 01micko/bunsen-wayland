#!/bin/bash
#
#   bunsenweather-wapi.sh: a conky weather script
#   Copyright (C) 2013 Ryan Fantus
#   Copyright (C) 2016 damo  <damo@bunsenlabs.org>
#   Copyright (C) 2024 micko01  <01micko@gmail.com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Requires:
##          'jq' (sudo apt-get install jq);
##          'owfont.ttf' from https://websygen.github.io/owfont/
## USAGE: Call this script from Conky with ( replace "<t>" with the update interval)
##          ${execpi <t> /path/to/bunsenweather-wapi.sh [location]}


#### User configurables:  ##############################################

# Get API KEY by registering for one at https://www.weatherapi.com
#api="your very long api number"

# Either set the location manually here, or by passing it as a script parameter in the Conky.
# "yourlocation" must be a name (replace spaces with '%20'), or lattidude,longitude up to 4 decimal spaces
#
# If $place is not set, then the script attempts to get a geolocation from the IP address.

#place="$1"              # Get $place from script parameter. (lat,lon)
place="" # set place here using %20 for spaces
#place="-27.9430,153.3916" # or use lat/long

# Choose fahrenheit/Imperial or Celcius/metric:
#metric='imperial'
metric='metric'

# NLS, change to native language if desired. See https://www.weatherapi.com/docs/#intro-location for supported codes
lang=en

# Fonts
text_font_bold='Sans:bold:size=10' # change to suit; note 'font1' is set in conkyrc
icon_font_L='owf\-regular:size=18'
icon_font_S='owf\-regular:size=10'

# Extra, wind and humity, comment not to show
show_extra=0
# 3 day forecast, comment not to show
show_forecast=0

# Colors also defined in conkyrc

#########################################################################
connectiontest() {
    local -i i attempts=${1-0}
    for (( i=0; i < attempts || attempts == 0; i++ )); do
        if wget -O - 'http://ftp.debian.org/debian/README' &> /dev/null; then
            return 0
        fi
        if (( i == attempts - 1 )); then # if last attempt
            return 1
        fi
    done
}

placeholder() {
    if (( $1 == 1 )) &>/dev/null;then
        echo "No internet connection"
        echo "Weather information unavailable"
    else
        echo "No API key"
        echo "Weather information unavailable"
    fi
}

get_icon () {
	case ${1:0:1} in
	    d)col='#D7D7D7';;
	    n)col='#6573A7';;
	esac
	case $1 in
		day-386|night-386)ico=Ueb28;;
		day-389|night-389)ico=Ueb29;;
		day-200|night-200)ico=Ueb32;;
		day-392|night-395|day-392|night-395)ico=Ueb46;;
		day-263|night-263|day-266|night-266|day-281|night-281|day-284|night-284| day-353|night-353)ico=Ueb8d;;
		day-293|night-293|day-296|night-296|day-356|night-356)ico=Ueb8e;;
		day-359|night-359)ico=Ueb99;;
		day-176|night-176)ico=Uec54;;
		day-299|night-299|day-302|night-302)ico=Uec56;;
		day-305|night-305|day-308|night-308)ico=Uec6a;;
		day-179|night-179|day-323|night-323|day-326| night-326)ico=Uecb8;;
		day-185|night-185|day-329|night-329|day-332|night-332|day-368|night-368)ico=Uecb9;;
		day-335|night-335|day-338|night-338|day-371|night-371)ico=Uecba;;
		day-182|night-182|day-227|night-227|day-230|night-230|day-311|night-311| day-362|night-362)ico=Uecc3;;
		day-314|night-314|day-365|night-365)ico=Uecc4;;
		day-314|night-314)ico=Uecc7;;
		day-320|night-320)ico=Uecc8;;
		day-143|night-143|day-248|night-2483|day-260|night-260)ico=Ued1d;;
		day-113)ico=Ued80;col=#E2DC5F;;
		night-113)ico=Uf168;col=#CECCA9;;
		day-116)ico=Ued81;col=#F4F2B4;;
		night-116)ico=Uf169;col=#CECCA9;;
		day-119|night-119|day-122|night-122)ico=Ued84;;
		day-350|night-350|day-374|night-374|day-377|night-377)ico=Uedea;;
	esac
}

if [[ $metric == metric ]] &>/dev/null;then
    unitT="°C"
    scaleT="c"
    scaleV="kph"
    unitV="km/h"
else
    unitT="°F"
    scaleT="f"
    scaleV="mph"
    unitV="mph"
fi

if [[ -z "$api" ]] &>/dev/null;then
    placeholder 0 && exit 1
else
    connectiontest 10

    # If latlong is preferred then don't set a value for $place
    if (( $? == 0 )) &>/dev/null;then
        if [[ -z $place ]] &>/dev/null;then
            # Geolocate IP:
            ipinfo=$(curl -s ipinfo.io)
            latlong=$(echo "$ipinfo" | jq -r '.loc')
            # Parse the latitude and longitude
            lat=${latlong%,*}
            long=${latlong#*,}
            location="q=$lat,$long"
        else
            # check if numeric id, or placename is being used
            [[ ${place##*[!0-9]*} ]] &>/dev/null && location="q=$place" || location="q=$place"
        fi

        # get json data from weatherapi:
        
        weather=$(curl -s http://api.weatherapi.com/v1/forecast.json\?key=$api\&$location\&days=3\&lang=$lang)
        city=$(echo "$weather" | jq -r '.location.name') # In case location has spaces in the name
        weather_desc=$(echo "$weather" | jq -r '.current.condition.text')   # In case description has spaces in the name
        
        # load values into array:
        allw=($(echo "$weather" | jq -r ".current.temp_$scaleT,.current.condition.icon,.current.wind_$scaleV,.current.wind_dir,.current.humidity,.forecast.forecastday[0].day.maxtemp_$scaleT,.forecast.forecastday[0].day.mintemp_$scaleT,.forecast.forecastday[1].day.maxtemp_$scaleT,.forecast.forecastday[1].day.mintemp_$scaleT,.forecast.forecastday[2].day.maxtemp_$scaleT,.forecast.forecastday[2].day.mintemp_$scaleT,.forecast.forecastday[0].day.condition.icon,.forecast.forecastday[1].day.condition.icon,.forecast.forecastday[2].day.condition.icon"))
        
        # get the icons
        cur_icon=${allw[1]/\/\/cdn.weatherapi.com\/weather\/64x64\//}
        cur_icon=${cur_icon/\.png/}
        cur_icon=${cur_icon/\//-}
        fore0_icon=${allw[11]/\/\/cdn.weatherapi.com\/weather\/64x64\//}
        fore0_icon=${fore0_icon/\.png/}
        fore0_icon=${fore0_icon/\//-}
        fore1_icon=${allw[12]/\/\/cdn.weatherapi.com\/weather\/64x64\//}
        fore1_icon=${fore1_icon/\.png/}
        fore1_icon=${fore1_icon/\//-}
        fore2_icon=${allw[13]/\/\/cdn.weatherapi.com\/weather\/64x64\//}
        fore2_icon=${fore2_icon/\.png/}
        fore2_icon=${fore2_icon/\//-}
        
        today=$(date +%A)
        today_epoch=$(echo "$weather" | jq -r '.forecast.forecastday[0].date_epoch')
        today_sunset_pre=$(echo "$weather" | jq -r '.forecast.forecastday[0].astro.sunset')
        today_sunset=$(date +%s -d "$today_sunset_pre")
        today_cond=$(echo "$weather" | jq -r '.forecast.forecastday[0].day.condition.text')
        today_cur_time=$(date +%s)
        tomorrow_epoch=$(echo "$weather" | jq -r '.forecast.forecastday[1].date_epoch')
        tomorrow_cond=$(echo "$weather" | jq -r '.forecast.forecastday[1].day.condition.text')
        tomorrow=$(date +%A -d @${tomorrow_epoch})
        next_day_epoch=$(echo "$weather" | jq -r '.forecast.forecastday[2].date_epoch')
        next_day_cond=$(echo "$weather" | jq -r '.forecast.forecastday[2].day.condition.text')
        next_day=$(date +%A -d @${next_day_epoch})


        col='#FFFFFF'
        ico=''
        get_icon $cur_icon
        printf "%s%s%s%b%s\n%s%s%s%s%s%s\n" "\${alignc}" "\${font $icon_font_L}" "\${$col}" "\\$ico" "\${color0}" "\${font $text_font_bold}" "${city}: " "\${font1}" "$weather_desc" "\${alignr}" "${allw[0]}$unitT"
        # extras
        if [[ -n "$show_extra" ]];then
            printf "%s%s%s %s\n%s%s%s\n" "Wind" "\${alignr}" "${allw[2]}$unitV" "${allw[3]}" "Humidity" "\${alignr}" "${allw[4]}%"
        fi
        # forecast
        if [[ -n "$show_forecast" ]];then
	        echo -e "\${font $text_font_bold}Forecast\${font1}"
	        if [[ $today_cur_time -lt $today_sunset ]];then # if late afternon don't show today's forecast
	            echo -e "$today"
	            get_icon $fore0_icon
	            printf "%s%s%b%s%s%s%s %s %s %s %s\n" "\${font $icon_font_S}" "\${$col}" "\\$ico" "\${color0}" "\${font1}" "\${alignr}" "$today_cond" "Max" "${allw[5]}$unitT" "Min" "${allw[6]}$unitT"
	        fi
	        echo -e "$tomorrow"
	        get_icon $fore1_icon
	        printf "%s%s%b%s%s%s%s %s %s %s %s\n" "\${font $icon_font_S}" "\${$col}" "\\$ico" "\${color0}" "\${font1}" "\${alignr}" "$tomorrow_cond" "Max" "${allw[7]}$unitT" "Min" "${allw[8]}$unitT"
	        echo -e "$next_day"
	        get_icon $fore2_icon
	        printf "%s%s%b%s%s%s%s %s %s %s %s\n" "\${font $icon_font_S}" "\${$col}" "\\$ico" "\${color0}" "\${font1}" "\${alignr}" "$next_day_cond" "Max" "${allw[9]}$unitT" "Min" "${allw[10]}$unitT"
        fi
    else
        placeholder 1
    fi 
fi

exit
