# TinyColor for LiveCode
This LiveCode Script library is based on Brian Grinstead's TinyColor v1.4.2 microframework. Which was translated into LiveCode Script by the FerrusLogic team

--
## How to use it
To use the TinyColor library, you must download the TinyColor.livecodescript file, which you must include as a library in your LiveCode project.

## How does it work
TinyColor works just like painting on a canvas. So we have to select a color to work with and smear our brush with this color. Once this is done, everything will be covered in this color. To smear our brush we call the tinyColor command and pass it the color we want to smear our brush with. This color must have a string format.
Example
```
tinyColor "rgb 255 0 0"
```
In the previous case, we smeared our brush with the color red. So from this moment we have all the operations that are carried out in tinyColor will be carried out with the color red. Except for the conversion functions from one color to another which we will see later. Do not confuse with obtaining the different versions of the color that these would return the equivalent value for the selected color in this case red.

It is also valid to clarify that we can use the TinyColor function which will have the same effect as the command, but it will return the color in the format that is passed to it within the array of the second parameter or in RGB string if it is not specified.

```
put TinyColor("#fff") --> returns rgb(255, 255, 255)
```

In this case the function will return the RGB string and also all operations will be performed on the color passed in the first parameter.

## Properties and transformations of the selected color