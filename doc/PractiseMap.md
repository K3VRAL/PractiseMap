# Name

PractiseMap - An application to practise sections of a map

# Synopsis

pracmap [-b file] [-o [file]] [-t start,end] [-g [time,amount]] [-r [time,position]] [-d] [-h]

# Description

PractiseMap is an application made to allow the user to splice sections of a map for the user to practise the sections. Since removing sections of a map may be costly for the osu!editor, this application will allow for the removal of objects to be easier. This application also allows for the prediction of RNG (both with and without the Hardrock mod) to allow for the user to practise RNG heavy segments.

# Resources

## Beatmap (`-b` or `--beatmap`) - File Location

Uses the beatmap file as input for difficulty, timing point, and hit object values to reference from.

If the argument is not used, it will default to `nil` and prevent the application from running.

## Output (`-o` or `--output`) - File Location

Uses the output file as output for all the stored objects that were identified to the modified beatmap.

If the argument is not used, it will default to the terminal's output.

## Time (`-t` or `--time`) - Formatted as `int,int`

Splices out a section of a map to practise in. Format for input is `start,end`.

If the argument is not used, it will default to `nil` and prevent the application from running.

## Beginning (`-g` or `--beginning`) - Formatted as `int,int`

Puts objects in a specific place and their amount. Mainly used for the Flashlight mod. Format for input is `time,amount`.

If the argument is not used, it will default to `nil` and be ignored.

You also can stack the argument multiple times, allowing you to have multiple object placements and their amounts.

## RNG (`-r` or `--rng`) - Formatted as `int,int`

Keeps track of the RNG before the practising of the map of the time argument. Places Banana Showers and Juice Streams to get the RNG to its correct form.

If the argument is not used, it will default to `nil` and be ignored.

## Hardrock (`-d` or `--hardrock`) - Boolean

Keeps track of the RNG including the Hardrock mod.`

If the argument is not used, it will default to `nil` and be ignored.

Requires the RNG argument to be used.

## Help (`-h` or `--help`) - Boolean

Gives all the commands to the terminal's output

# Authors

K 3 V R A L