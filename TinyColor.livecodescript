script "tinyColor"
--------------------------------------------------------------------------------------------------------------------------
# This code is based on the TinyColor v1.4.2 micro framework created by Brian Grinstead.
# Which we can find at https://github.com/bgrins/TinyColor.
#
#  Name: TinyColor
#  Type: Library
#  Version: v1.0.0b
#  Translate code to livecode script: FerrusLogic team
#  Code repository: https://github.com/Ferruslogic/PhotonJSON/
#  Web: https://ferruslogic.com/
#  License: https://opensource.org/licenses/MIT
#  Description: Fast, small color manipulation and conversion for LiveCode.
--------------------------------------------------------------------------------------------------------------------------


local sTinyCounter = 0, sColor, sHexNames

# Parameters
# pColor: Color en formato string
# pOpts["format"]: Output format
# pOpts["gradientType"]: Gradient type
function tinyColor pColor, pOpts
   local rgb, tFormat
   
   delete local sColor
   
   put inputToRGB( pColor ) into rgb
   if rgb is empty then return "error: input is not string color"

   put pColor into sColor["originalInput"]
   put rgb["r"] into sColor["r"]
   put rgb["g"] into sColor["g"]
   put rgb["b"] into sColor["b"]
   put rgb["a"] into sColor["a"]
   
   if sColor["a"] is not a number then put 0 into sColor["a"]
   put round(100* sColor["a"]) / 100 into sColor["roundA"]
   if  rgb["a"] is a integer then put rgb["a"] into sColor["a"]
   
   put pOpts["format"] into tFormat
   
   if rgb["format"] is "" then put "rgb" into rgb["format"]
   put rgb["format"] into sColor["format"]
   put pOpts["gradientType"] into sColor["gradientType"]
   
   // Don't let the range of [0,255] come back in [0,1].
   // Potentially lose a little bit of precision here, but will fix issues where
   // .5 gets interpreted as half of the total, instead of half of 1
   // If it was supposed to be 128, this was already taken care of by `inputToRgb`
   if sColor["r"] < 1 then put trunc( sColor["r"] ) into sColor["r"]
   if sColor["g"] < 1 then put trunc( sColor["g"] ) into sColor["g"]
   if sColor["b"] < 1 then put trunc( sColor["b"] ) into sColor["b"]
   
   put rgb["ok"] into sColor["ok"]
   
   add 1 to sTinyCounter
   put sTinyCounter into sColor["tc_id"]
   
   return toString(tFormat)
end tinyColor


command tinyColor pColor
    get tinyColor(pColor)
end tinyColor



function getSystemAppearance
   switch platform()
      
      case "Win32"
         local tType, tData, tDataReady
         put queryRegistry("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme",tType) into tData
         put empty into tDataReady
         
         repeat for each char tchar in tData
            put chartonum(tchar) after tDataReady
         end repeat
         
         if tDataReady is "1000" then return "light"
         else  if tDataReady is "0000" then return "dark"
         return "undefined"
         break
         
      case "MacOS";case "iphone";case "android"
         if the systemAppearance contains "dark" then
            return "dark"
         else
            return "light"
         end if
         break
   end switch
end getSystemAppearance


#### on tinyColor.prototype ####
function isDark
    return getBrightness() < 128
end isDark

function isLight
    return not isDark()
end isLight

function isValid
    return sColor["ok"] is true
end isValid

function getOriginalInput
    return sColor["originalInput"]
end getOriginalInput

function getFormat
    return sColor["format"]
end getFormat

function getAlpha
    return sColor["a"]
end getAlpha

function getBrightness pRGB
    // http://www.w3.org/TR/AERT#color-contrast
   local tRGB
   
    put _fixRGB(pRGB) into tRGB
    return (tRGB["r"] * 299 + tRGB["g"] * 587 + tRGB["b"] * 114) / 1000
end getBrightness

function getLuminance pRGB
   local tRGB, RsRGB, GsRGB, BsRGB, R, G, B
   
    put _fixRGB(pRGB) into tRGB
    // http://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef
    split tRGB by comma
    put tRGB[1]/255 into RsRGB
    put tRGB[2]/255 into GsRGB
    put tRGB[3]/255 into BsRGB

    if RsRGB <= 0.03928 then put RsRGB / 12.92 into R
    else put ((RsRGB + 0.055) / 1.055)^2.4 into R

    if GsRGB <= 0.03928 then put GsRGB / 12.92 into G
    else put ((GsRGB + 0.055) / 1.055)^2.4 into G

    if BsRGB <= 0.03928 then put BsRGB / 12.92 into B
    else put ((BsRGB + 0.055) / 1.055)^2.4 into B

    return (0.2126 * R) + (0.7152 * G) + (0.0722 * B)
end getLuminance

command  setAlpha pValue
    put boundAlpha(pValue) into sColor["a"]
    put round(100 * sColor["a"]) / 100 into sColor["roundA"]
    return sColor
end setAlpha

-------------------------------------
function toHsv
   local hsv, h, s, v
   
   put rgbToHsv(sColor["r"], sColor["g"], sColor["b"]) into hsv
   split hsv by comma
   put round(hsv[1] * 360) into h
   put round(hsv[2] * 100) into s
   put round(hsv[3] * 100) into v
   
   if sColor["a"] is 0 then return  h & ", " & s & "%, " & v & "%"
   else return h & ", " & s & "%, " & v & "%, " & sColor["roundA"]
end toHsv


function toHsvString
   if sColor["a"] is 0 then return "hsv(" & toHsv() & ")"
   else return "hsva( " & toHsv() & ", " & sColor["roundA"] & " )"
end toHsvString


function toHsl
   local hsl, h, s, l
   put rgbToHsl(sColor["r"], sColor["g"], sColor["b"]) into hsl
   put round(the item 1 of hsl * 360) into h
   put round(the item 2 of hsl * 100) into s
   put round(the item 3 of hsl * 100) into l
   
   if sColor["a"] is 0 then return  h,s & "%, " & l & "%"
   else return  h,s & "%, " & l & "%" & sColor["roundA"] 
end toHsl

function toHslString
   if sColor["a"] is 0 then return "hsl("  & toHsl() & "%)"
   else return "hsla( " & toHsl() & ", " & sColor["roundA"] &  " )"
end toHslString

function toHex allow3Char
    return rgbToHex(sColor["r"], sColor["g"], sColor["b"], allow3Char);
end toHex

function toHexString allow3Char
    return toHex(allow3Char)
end toHexString

function toHex8 allow4Char
    return rgbaToHex(sColor["r"], sColor["g"], sColor["b"], sColor["a"], allow4Char);
end toHex8


function toHex8String allow4Char
    return  toHex8(allow4Char)
end toHex8String


function toRgb pValues
    if pValues is not true then
        return "{ r:" & round(sColor["r"])," g:" & round(sColor["g"])," b:" & round( sColor["b"])," a:" &  sColor["a"] & "}"
    else
        if  sColor["a"]  is not a number and  sColor["a"] is not in "0 1" then
            return  round(sColor["r"]), round(sColor["g"]), round( sColor["b"]) ,sColor["a"]
        else
            return  round(sColor["r"]), round(sColor["g"]), round( sColor["b"]) 
        end if
    end if
end toRgb


function toRgbString
    if sColor["a"] is a number then return "rgb("  & round(sColor["r"]) &", " & round(sColor["g"])& ", " & round(sColor["b"]) & ")"
    else return "rgba( " & round(sColor["r"])& ", " & round(sColor["g"]) & ", " & round(sColor["b"])& ", " & sColor["roundA"] & " )"
end toRgbString


function toPercentageRgb
    return "{ r:" & round( bound01(sColor["r"], 255) * 100) & "%, g:" & round(bound01(sColor["g"], 255) * 100) & "% , b:" & round(bound01(sColor["b"], 255) * 100) & "%, a:" & sColor["a"] & "}"
end toPercentageRgb


function toPercentageRgbString
    if sColor["a"] is 0 then
        return "rgb("  && round(bound01( sColor["r"], 255) * 100) & "%, " && round(bound01(sColor["g"], 255) * 100) & "%, " && round(bound01(sColor["b"], 255) * 100) & "%)"
    else
        return "rgba("  && round(bound01( sColor["r"], 255) * 100) & "%, " && round(bound01(sColor["g"], 255) * 100) & "%, " && round(bound01(sColor["b"], 255) * 100) & "%, " && sColor["a"] &  ")";
    end if
end toPercentageRgbString


---> 539 different color names 
function toName
    local  r, g, b, tColorNames, tResult = ""
    if sColor["a"] is 100 then return "transparent"
    if sColor["a"] < 0  and sColor["a"] is not empty then return false
    put getColorArray() into tColorNames

    put toLower(tColorNames["rgb"][round(sColor["r"]), round(sColor["g"]),round(sColor["b"])]) into tResult
    if tResult is empty then return "none"
    return tResult
end toName

local sColorArray
private function getColorArray
    local  tColorNames, rgb, tem

    put the colorNames into tColorNames
    put "darkturquoise|0,206,209@palegoldenrod|238,232,170@azure|240,255,255@lightgray|211,211,211@darkseagreen|143,188,143@royalblue|65,105,225@khaki|240,230,140@silver|192,192,192@mediumpurple|147,112,219@purple|128,0,128@gainsboro|220,220,220@darkslateblue|72,61,139@palegreen|152,251,152@darkorange|255,140,0@lightgrey|211,211,211@maroon|128,0,0@mediumorchid|186,85,211@lightsteelblue|176,196,222@darkgoldenrod|184,134,11@darkkhaki|189,183,107@hotpink|255,105,180@mediumseagreen|60,179,113@coral|255,127,80@rosybrown|188,143,143@teal|0,128,128@midnightblue|25,25,112@plum|221,160,221@violet|238,130,238@linen|250,240,230@gold|255,215,0@floralwhite|255,250,240@chocolate|210,105,30@lavender|230,230,250@indigo|75,0,130@slategrey|112,128,144@darkolivegreen|85,107,47@ghostwhite|248,248,255@sandybrown|244,164,96@peru|205,133,63@firebrick|178,34,34@burlywood|222,184,135@aliceblue|240,248,255@lightgoldenrodyellow|250,250,210@darkslategrey|47,79,79@darksalmon|233,150,122@skyblue|135,206,235@ivory|255,255,240@lightcoral|240,128,128@mintcream|245,255,250@pink|255,192,203@saddlebrown|139,69,19@papayawhip|255,239,213@lightskyblue|135,206,250@olivedrab|107,142,35@darkslategray|47,79,79@beige|245,245,220@lightslategrey|119,136,153@lightpink|255,182,193@blanchedalmond|255,235,205@brown|165,42,42@olive|128,128,0@cadetblue|95,158,160@palevioletred|219,112,147@slategray|112,128,144@lightslategray|119,136,153@moccasin|255,228,181@wheat|245,222,179@thistle|216,191,216@salmon|250,128,114@oldlace|253,245,230@powderblue|176,224,230@burntsienna|234,126,93@crimson|220,20,60@rebeccapurple|102,51,153@mediumturquoise|72,209,204@paleturquoise|175,238,238@orange|255,165,0@green|0,128,0@cornsilk|255,248,220@darkorchid|153,50,204@darkviolet|148,0,211@antiquewhite|250,235,215@" into tem
    split tem by "@" and "|"
    put tem into sColorArray["name"]

    put "0,206,209|darkturquoise@238,232,170|palegoldenrod@240,255,255|azure@211,211,211|lightgray@143,188,143|darkseagreen@65,105,225|royalblue@240,230,140|khaki@192,192,192|silver@147,112,219|mediumpurple@128,0,128|purple@220,220,220|gainsboro@72,61,139|darkslateblue@152,251,152|palegreen@255,140,0|darkorange@211,211,211|lightgrey@128,0,0|maroon@186,85,211|mediumorchid@176,196,222|lightsteelblue@184,134,11|darkgoldenrod@189,183,107|darkkhaki@255,105,180|hotpink@60,179,113|mediumseagreen@255,127,80|coral@188,143,143|rosybrown@0,128,128|teal@25,25,112|midnightblue@221,160,221|plum@238,130,238|violet@250,240,230|linen@255,215,0|gold@255,250,240|floralwhite@210,105,30|chocolate@230,230,250|lavender@75,0,130|indigo@112,128,144|slategrey@85,107,47|darkolivegreen@248,248,255|ghostwhite@244,164,96|sandybrown@205,133,63|peru@178,34,34|firebrick@222,184,135|burlywood@240,248,255|aliceblue@250,250,210|lightgoldenrodyellow@47,79,79|darkslategrey@233,150,122|darksalmon@135,206,235|skyblue@255,255,240|ivory@240,128,128|lightcoral@245,255,250|mintcream@255,192,203|pink@139,69,19|saddlebrown@255,239,213|papayawhip@135,206,250|lightskyblue@107,142,35|olivedrab@47,79,79|darkslategray@245,245,220|beige@119,136,153|lightslategrey@255,182,193|lightpink@255,235,205|blanchedalmond@165,42,42|brown@128,128,0|olive@95,158,160|cadetblue@219,112,147|palevioletred@112,128,144|slategray@119,136,153|lightslategray@255,228,181|moccasin@245,222,179|wheat@216,191,216|thistle@250,128,114|salmon@253,245,230|oldlace@176,224,230|powderblue@234,126,93|burntsienna@220,20,60|crimson@102,51,153|rebeccapurple@72,209,204|mediumturquoise@175,238,238|paleturquoise@255,165,0|orange@0,128,0|green@255,248,220|cornsilk@153,50,204|darkorchid@148,0,211|darkviolet@250,235,215|antiquewhite@" into tem
    split tem by "@" and "|"
    put tem into sColorArray["rgb"]


    repeat for each line tName in tColorNames
        -- Colors that have the same RGB as others. Ej gray0 = black
        if tName is among the words of "Yellow1 Gray100 IndianRed4 Tan3 SeaGreen4 DarkSalmon DarkOrange4 Firebrick3 PaleGreen2 OrangeRed4 NavyBlue gray0 Azure1 Chartreuse1 Coral1 CornSilk1 Chocolate1 Chocolate2 Chocolate3  Chocolate4 Firebrick4 Ivory1 LightCyan1 Magenta4 Aquamarine3"
        then next repeat

        put getRgbFromColor(tName) into rgb
        put rgb into sColorArray["name"][tName]
        put tName into sColorArray["rgb"][rgb]
    end repeat

    return sColorArray
end getColorArray


function toFilter pSecondColor
    local hex8String, secondHex8String, gradientType

    put "#" & rgbaToArgbHex(sColor["r"],sColor["g"],sColor["b"], sColor["a"]) into hex8String
    put hex8String into secondHex8String

    if sColor["gradientType"] then put "GradientType = 1, " into gradientType
    else put "" into gradientType

    if pSecondColor then
        get tinyColor(pSecondColor)
        put "#" & rgbaToArgbHex(sColor["r"], sColor["g"], sColor["b"], sColor["a"]) into secondHex8String
    end if

    return "progid:DXImageTransform.Microsoft.gradient(" & gradientType & "startColorstr=" & hex8String & ",endColorstr=" & secondHex8String & ")"
end toFilter


function toString pFormat
   local formatSet, formattedString = false, hasAlpha, needsAlphaFormat
   
   if pFormat is empty then put sColor["format"] into pFormat
   
   put sColor["a"] < 1 and sColor["a"] >= 0 into hasAlpha
   --put not formatSet and hasAlpha and (pFormat is among the items "rgb,rgba,hex,hex6,hex3,hex4,hex8,name") into needsAlphaFormat
   
   if needsAlphaFormat then
      // Special case for "transparent", all other non-alpha formats
      // will return rgba when there is transparency.
      if pFormat is "name"  then
         return toName()
      end if
      
      return toRgbString()
   end if
   
   switch pFormat
      case "rgb"
         return toRgbString()
         break
         
      case "prgb"
         return toPercentageRgbString()
         break
         
      case "hex"; case "hex6"
         return toHexString()
         break
         
      case "hex3"
         return toHexString(true)
         break
         
      case "hex4"
         return toHex8String(true)
         break
         
      case "hex8"
         return toHex8String()
         break
         
      case "name"
         return toName()
         break
         
      case  "hsl"
         return toHslString()
         break
         
      case "hsv"
         return toHsvString()
         break   
         
      default
         return toHexString()
   end switch
   
end toString

private function tinyClone
    return toString()
end tinyClone

#### END tinyColor.prototype ####
// If input is an object, force 1 into "1.0" to handle ratios properly
// String input requires "1.0" as input, so 1 will be treated as 1
function tinyColor.fromRatio pColor, opts
    local newColor
    if typeof(pColor) is "object" then
        repeat for each key i in pColor
            if pColor[i] is not empty then
                if i is "a" then
                    put pColor[i] into newColor[i]
                else
                    put convertToPercentage(pColor[i]) into newColor[i]
                end if
            end if
        end repeat
        put newColor into pColor
    end if
    return tinyColor( pColor, opts)
end tinyColor.fromRatio




// Given a string or object, convert that input to RGB
// Possible string inputs:
//
//     "red"
//     "#f00" or "f00"
//     "#ff0000" or "ff0000"
//     "#ff000000" or "ff000000"
//     "rgb 255 0 0" or "rgb (255, 0, 0)"
//     "rgb 1.0 0 0" or "rgb (1, 0, 0)"
//     "rgba (255, 0, 0, 1)" or "rgba 255, 0, 0, 1"
//     "rgba (1.0, 0, 0, 1)" or "rgba 1.0, 0, 0, 1"
//     "hsl(0, 100%, 50%)" or "hsl 0 100% 50%"
//     "hsla(0, 100%, 50%, 1)" or "hsla 0 100% 50%, 1"
//     "hsv(0, 100%, 100%)" or "hsv 0 100% 100%"
//
function inputToRGB pColor
    local  rgb, tFormat  = false, ok = false, tResult, tAlfa, input
    local tName

    put pColor into tName
    replace space with "" in tName

    # Input is color name
    if tName is among the lines of the colorNames then
        put getRgbFromColor(tName) into rgb
        split rgb by comma
        put rgb[1] into tResult["r"]
        put rgb[2] into tResult["g"]
        put rgb[3] into tResult["b"]
        put "name" into tResult["format"]
        put true into tResult["ok"]
    end if

    # Input is color Hex
    if the number of words of pColor is 1 and isHex(pColor) is true then
        replace space with "" in pColor
        if not (pColor begins with "#") then  put "#" & pColor into pColor
        put getRgbFromColor(the char 1 to 7 of pColor) into rgb
        split rgb by comma
        put rgb[1] into tResult["r"]
        put rgb[2] into tResult["g"]
        put rgb[3] into tResult["b"]
        put "hex" into tResult["format"]
        put true into tResult["ok"]
    end if

    if tResult["format"] is empty and typeof(pColor) is "string" then  put stringInputToObject(pColor) into pColor

    if typeof(pColor) is "object" then
        _objectToArray pColor

        if isValidCSSUnit(pColor["r"]) and isValidCSSUnit(pColor["g"]) and isValidCSSUnit(pColor["b"]) then
            put rgbToRgb(pColor["r"], pColor["g"], pColor["b"]) into rgb

            if pColor["r"] ends with "%" then
                put "prgb" into tFormat
            else
                put "rgb" into tFormat
            end if

            split rgb by comma
            put rgb[1] into tResult["r"]
            put rgb[2] into tResult["g"]
            put rgb[3] into tResult["b"]
            put tFormat into tResult["format"]
            put true into tResult["ok"]

        else if isValidCSSUnit(pColor["h"]) and isValidCSSUnit(pColor["s"]) and isValidCSSUnit(pColor["v"]) then
            put convertToPercentage(pColor["s"]) into pColor["s"]
            put convertToPercentage(pColor["v"]) into pColor["v"]
            put hsvToRgb(pColor["h"], pColor["s"], pColor["v"]) into rgb
            split rgb by comma
            put rgb[1] into tResult["r"]
            put rgb[2] into tResult["g"]
            put rgb[3] into tResult["b"]
            put "hsv" into tResult["format"]
            put true into tResult["ok"]

        else if isValidCSSUnit(pColor["h"]) and isValidCSSUnit(pColor["s"]) and isValidCSSUnit(pColor["l"]) then
            put convertToPercentage(pColor["s"]) into pColor["s"]
            put convertToPercentage(pColor["l"]) into pColor["l"]
            put hslToRgb(pColor["h"], pColor["s"], pColor["l"]) into rgb
            split rgb by comma
            put rgb[1] into tResult["r"]
            put rgb[2] into tResult["g"]
            put rgb[3] into tResult["b"]
            put "hsl" into tResult["format"]
            put true into tResult["ok"]

        end if
    end if

    if rgb[4] is not empty then  put rgb[4] into tAlfa

    put boundAlpha( tAlfa ) into tAlfa
    if the number of elements of tResult < 5 then
        return empty for value
    end if

    put min(255, max(tResult["r"], 0)) into tResult["r"]
    put min(255, max(tResult["g"], 0)) into tResult["g"]
    put min(255, max(tResult["b"], 0)) into tResult["b"]

    return tResult for value
end inputToRGB




// Conversion Functions
// --------------------
// `rgbToHsl`, `rgbToHsv`, `hslToRgb`, `hsvToRgb` modified from:
// <http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript>

// `rgbToRgb`
// Handle bounds / percentage checking to conform to CSS color spec
// <http://www.w3.org/TR/css3-color/>
// *Assumes:* r, g, b in [0, 255] or [0, 1]
// *Returns:* r, g, b in [0, 255]
function rgbToRgb r, g, b
    if ("." is in r or "." is in g or "." is in b ) and max(r, g, b) <= 1 then
        put r * 255 into r
        put g * 255 into g
        put b * 255 into b
    end if
    return bound01(r, 255) * 255, bound01(g, 255) * 255, bound01(b, 255) * 255
end rgbToRgb


// `rgbToHsl`
// Converts an RGB color value to HSL.
// *Assumes:* r, g and b are contained in [0, 255] or [0, 1]
// *Returns:* h, s, l in [0,1]
function rgbToHsl r, g, b
    local tMx, tMn,  h, s, l, d

    put bound01(r,255) into r
    put bound01(g,255) into g
    put bound01(b,255) into b

    put max(r,g,b) into tMx
    put min(r,g,b) into tMn

    put (tMx + tMn) / 2 into l

    if tMx is tMn then
        // achromatic
        put 0 into h
        put 0 into s
    else
        put tMx - tMn into d

        if l > 0.5 then
            put d / (2 - tMx - tMn) into s
        else
            put d / (tMx + tMn) into s
        end if

        switch tMx
            case r
                local t
                if g < b then
                    put 6 into t
                else
                    put 0 into t
                end if
                put (g - b) / d + t into h
                break

            case g
                put (b - r) / d + 2 into h
                break

            case b
                put (r - g) / d + 4 into  h
                break
        end switch

        put h/6 into h
    end if

    return  h, s, l
end rgbToHsl


// `hslToRgb`
// Converts an HSL color value to RGB.
// *Assumes:* h is contained in [0, 1] or [0, 360] and s and l are contained [0, 1] or [0, 100]
// *Returns:* r, g, b in the set [0, 255]
function hslToRgb h, s, l
    local r, g, b ,q, p

    put bound01(h, 360) into h
    put bound01(s, 100) into s
    put bound01(l, 100) into l

    if s is 0 then
        // achromatic
        put  round(l * 255) into l
        return l, l,l
    else
        if l < 0.5 then
            put l * (1 + s) into q
        else
            put l + s - l * s into q
        end if

        put 2 * l - q into p
        put hue2rgb(p, q, h + 1/3) into r
        put hue2rgb(p, q, h) into g
        put hue2rgb(p, q, h - 1/3) into b
    end if

    return  round(r * 255), round(g * 255), round(b * 255)
end hslToRgb


private function hue2rgb p, q, t
    if t < 0 then add 1 to t
    if t > 1  then subtract 1 from t
    if t < 1/6 then  return p + (q - p) * 6 * t
    if t < 1/2 then return q
    if t < 2/3 then return p + (q - p) * (2/3 - t) * 6
    return p
end hue2rgb



// `rgbToHsv`
// Converts an RGB color value to HSV
// *Assumes:* r, g, and b are contained in the set [0, 255] or [0, 1]
// *Returns:*  h, s, v  in [0,1]
function rgbToHsv r, g, b
    local tMx, tMn, d, h, s, v
    put bound01(r, 255) into r
    put bound01(g, 255) into g
    put bound01(b, 255) into b

    put max(r, g, b) into tMx
    put min(r, g, b) into tMn
    put tMx into h
    put tMx into s
    put tMx into v
    put tMx - tMn into d
    if tMx is 0 then
        put 0 into s
    else
        put d/ tMx into s
    end if

    if tMx is tMn then
        put 0 into h // achromatic
    else
        switch tMx
            case r
            if g < b then
                put (g - b) / d + 6 into h
            else
                put (g - b) / d into h
            end if
            break
            case g
            put (b - r) / d + 2 into h
            break
            case b
            put (r - g) / d + 4 into h
            break
        end switch

        put h/6 into h
    end if
    return h, s, v
end rgbToHsv


// `hsvToRgb`
// Converts an HSV color value to RGB.
// *Assumes:* h is contained in [0, 1] or [0, 360] and s and v are contained in [0, 1] or [0, 100]
// *Returns:*  r, g, b in the set [0, 255]
function hsvToRgb h, s, v
    local i, f, p , q, t, tMod, r, g ,b
    put bound01(h, 360) * 6 into h
    put bound01(s, 100) into s
    put bound01(v, 100) into v

    put floor(h) into i
    put h - i into f
    put v * (1 - s) into p
    put v * (1 - f * s) into q
    put v * (1 - (1 - f) * s) into t
    put i mod 6 into tMod
    add 1 to tMod
    put item tMod of (v, q, p, p, t, v) into r
    put item tMod of (t, v, v, q, p, p) into g
    put item tMod of (p, p, t, v, v, q) into b
    return r * 255, g * 255, b * 255
end hsvToRgb



// `rgbToHex`
// Converts an RGB color to hex
// Assumes r, g, and b are contained in the set [0, 255]
// Returns a 6 character hex
function rgbToHex r, g, b, allow3Char
    local hex
    put baseconvert( round(r),10,16 ) into r
    if the length  of r < 2 then put 0 &  r into r
    put baseconvert( round(g),10,16 ) into g
    if the length  of g < 2 then put 0 &  g into g
    put baseconvert( round(b),10,16 ) into b
    if the length  of b < 2 then put 0 &  b into b
    return "#" & toLower( r & g & b)
end rgbToHex



// `rgbaToHex`
// Converts an RGBA color plus alpha transparency to hex
// Assumes r, g, b are contained in the set [0, 255] and
// a in [0, 1]. Returns a 4 or 8 character rgba hex
function rgbaToHex r, g, b, pA, allow4Char
    local hex, tA

    put baseconvert( round(r),10,16 ) into r
    if the length  of r < 2 then put 0 &  r into r
    put baseconvert( round(g),10,16 ) into g
    if the length  of g < 2 then put 0 &  g into g
    put baseconvert( round(b),10,16 ) into b
    if the length  of b < 2 then put 0 &  b into b
    put convertDecimalToHex(pA) into tA
    put baseconvert( round(tA),10,16 ) into tA
    if the length  of tA < 2 then put 0 &  tA into tA

    return "#" & toLower( r & g & b & tA)
end rgbaToHex


// `rgbaToArgbHex`
// Converts an RGBA color to an ARGB Hex8 string
// Rarely used, but required for "toFilter()"
function rgbaToArgbHex r, g, b, pA
    local hex, tA

    put baseconvert( round(r),10,16 ) into r
    if the length  of r < 2 then put 0 &  r into r
    put baseconvert( round(g),10,16 ) into g
    if the length  of g < 2 then put 0 &  g into g
    put baseconvert( round(b),10,16 ) into b
    if the length  of b < 2 then put 0 &  b into b
    put convertDecimalToHex(pA) into tA
    put baseconvert( round(tA),10,16 ) into tA
    if the length  of tA < 2 then put 0 &  tA into tA

    return "#" & r & g & b & tA
end rgbaToArgbHex


// `equals`
// Can be called with any tinyColor input
function tinyColor.equals color1, color2
    if color1 is empty or color2 is empty then return false
     tinyColor color1
     put toRgbString() into color1

    tinyColor color2
    put toRgbString() into color2

    return color1 is color2
end tinyColor.equals

function tinyColor.random
    return tinyColor.fromRatio(random(255),random(255),random(255))
end tinyColor.random



// Modification Functions
// ----------------------
// Thanks to less.js for some of the basics here
// <https://github.com/cloudhead/less.js/blob/master/lib/less/functions.js>

function desaturate pColor, amount
    local hsl, l, tBaseColor, tDesaturateColor

    put sColor into tBaseColor
    if pColor is not empty then tinyColor pColor
    if amount is not an integer then put 20 into amount

    put toHsl() into hsl
    _objectToArray hsl

    put hsl["s"] - (amount / 100) into hsl["s"]
    put clamp01(hsl["s"]) into  hsl["s"]

    put tinyColor("hsl" && hsl["h"] & ", " & hsl["s"] & ", " & hsl["l"]) into tDesaturateColor

    if tBaseColor is not empty then put tBaseColor into sColor
    return tDesaturateColor
end desaturate


function saturate pColor, amount
    local hsl, l, tBaseColor, tSaturateColor
    put sColor into tBaseColor

    if pColor is not empty then tinyColor pColor
    if amount is not an integer then put 20 into amount

    put toHsl() into hsl
    _objectToArray hsl

    put hsl["s"] + (amount / 100) into hsl["s"]
    put clamp01(hsl["s"]) into  hsl["s"]

    put tinyColor("hsl" && hsl["h"] & ", " & hsl["s"] & ", " & hsl["l"]) into tSaturateColor

    if tBaseColor is not empty then put tBaseColor into sColor
    return tSaturateColor
end saturate


function greyScale pColor
    return desaturate(pColor, 100)
end greyScale

function lighten pColor, amount
    local hsl, l, tBaseColor, tLightenColor
    put sColor into tBaseColor

    if pColor is not empty then tinyColor pColor
    if amount is not an integer then put 20 into amount

    put toHsl() into hsl
    _objectToArray hsl

    put amount/ 100  + hsl["l"]  into hsl["l"]
    put clamp01(hsl["l"]) into  hsl["l"]
    put tinyColor("hsl" && hsl["h"] & ", " & hsl["s"] & ", " & hsl["l"]) into tLightenColor

    if tBaseColor is not empty then put tBaseColor into sColor
    return tLightenColor
end lighten


function brighten pColor, amount
    local rgb, tBaseColor, tBrightenColor

    put sColor into tBaseColor

    if amount is not an integer then put 20 into amount
    if pColor is not empty then  tinyColor pColor
    put toRgb() into rgb
    _objectToArray rgb

    put max(0, min(255, rgb["r"] - round(255 * - (amount / 100)))) into rgb["r"]
    put max(0, min(255, rgb["g"] - round(255 * - (amount / 100)))) into rgb["g"]
    put max(0, min(255, rgb["b"] - round(255 * - (amount / 100)))) into rgb["b"]

    tinyColor ("rgb" && rgb["r"] && rgb["g"] && rgb["b"])
    put toRgb(true) into tBrightenColor
    put tBaseColor into sColor

    return tBrightenColor
end brighten


function darken pColor, amount
    local hsl, l, tBaseColor, tDarkenColor
    put sColor into tBaseColor

    if pColor is not empty then tinyColor pColor
    if amount is not an integer then put 20 into amount

    put toHsl() into hsl
    _objectToArray hsl

    put hsl["l"] - amount / 100 into hsl["l"]
    put clamp01( hsl["l"]) into  hsl["l"]
    put tinyColor("hsl" && hsl["h"] & ", " & hsl["s"] & ", " & hsl["l"]) into tDarkenColor

    if tBaseColor is not empty then put tBaseColor into sColor
    return tDarkenColor
end darken


// Spin takes a positive or negative amount within [-360, 360] indicating the change of hue.
// Values outside of this range will be wrapped into this range.
function spin pColor, amount
    local hsl, hue
    get tinyColor(pColor)
    put toHsl() into hsl
    _objectToArray hsl
    put (hsl["h"] + amount) mod 360 into hue
    if hue < 0 then
        put 360 + hue into hsl["h"]
        else
        put hue into hsl["h"]
    end if
    return tinyColor("hsl" &&  hsl["h"] & ", "&  hsl["s"] & ", "&  hsl["l"]);
end spin


// Combination Functions
// ---------------------
// Thanks to jQuery xColor for some of the ideas behind these
// <https://github.com/infusion/jQuery-xcolor/blob/master/jquery.xcolor.js>

function complement pColor
    local hsl
    get tinyColor(pColor)
    put toHsl() into hsl
    _objectToArray hsl
    put (hsl["h"] + 180) mod 360 into hsl["h"]
    return tinyColor("hsl" &&  hsl["h"] & ", "&  hsl["s"] & ", "&  hsl["l"])
end complement


function triad pColor
    local hsl, h, triad, tColor, tOldColor

    put sColor into tOldColor

    tinyColor pColor
    put toHsl() into hsl
    _objectToArray hsl
    put hsl["h"] into h

    put toRgb(true) into triad[ 1 ]
    put "{ h:" && (h + 120) mod 360, "s: " & hsl["s"], "l: " & hsl["l"] & " }" into tColor
    tinyColor tColor

    put toRgb(true) into triad[2]
    put "{ h:" && (h + 240) mod 360, "s: " & hsl["s"], "l: " & hsl["l"] & " }" into tColor
    tinyColor tColor

    put toRgb(true) into triad[3]
    put tOldColor into sColor
    return triad
end triad


function tetrad pColor
    local hsl, h, tetrad, tColor, tOldColor

    put sColor into tOldColor

    tinyColor pColor
    put toHsl() into hsl
    _objectToArray hsl
    put toRgb(true) into tetrad[ 1 ]

    put "{ h:" & (h + 90) mod 360, "s: " & hsl["s"], "l: " & hsl["l"] && "}" into tColor
    tinyColor tColor
    put toRgb(true) into tetrad[2]

    put  "{ h:" & (h + 180) mod 360, "s: " & hsl["s"], "l: " & hsl["l"] && "}" into tColor
    tinyColor tColor
    put toRgb(true) into tetrad[3]

    put  "{ h:" & (h + 270) mod 360, "s: " & hsl["s"], "l: " & hsl["l"] && "}" into tColor
    tinyColor tColor
    put toRgb(true) into tetrad[4]

    return tetrad
end tetrad


function splitcomplement pColor
    local hsl, h,  tSplitcomplement,  tOldColor

    put sColor into tOldColor
    tinyColor pColor

    put toHsl() into hsl
    put toRgb(true) into tSplitcomplement[ 1 ]
    _objectToArray hsl
    put hsl["h"] into h

    tinyColor ("{ h: " & (h + 72) mod 360, "s:" && hsl["s"], "l:" && hsl["l"] & " }")
    put toRgb(true) into tSplitcomplement[ 2 ]

    tinyColor("{ h: " & (h + 216) mod 360, "s:" && hsl["s"], "l:" && hsl["l"] & " }")
    put toRgb(true) into tSplitcomplement[ 3 ]
    put tOldColor into sColor
    return tSplitcomplement
end splitcomplement


function analogous pColor, pResults, pSlices
    local hsl, tColor, tPart, ret,  tOldColor, tResult

    put sColor into tOldColor
    if pResults is no an integer then put 6 into pResults
    if pSlices is no an integer then put 30 into pSlices

    tinyColor pColor
    put toHsl() into hsl
    _objectToArray hsl

    put 360 / pSlices into tPart
    tinycolor pColor
    put toRgb(true) into tResult[ 1 ]

    put (( hsl[ "h" ] - (  tPart * _rightShift( pResults , 1 )) )+ 720 ) mod 360 into hsl[ "h" ]

    local index = 1
    repeat with x = (pResults - 1 ) down to 1
        add 1 to index
        put  ( hsl[ "h" ] + tPart ) mod 360 into hsl[ "h" ]

        tinyColor ("hsl" &&  hsl["h"] & ", "&  hsl["s"] & ", "&  hsl["l"])
        put toRgb(true) into tResult[ index ]

    end repeat

    --    repeat for each key k in tResult
    --        put empty into tResult[k]
    --    end repeat

    put tOldColor into sColor
    return tResult
end analogous



function monochromatic pColor, results
    local hsv, tColor, ret, h, s, v, modification, tOldColor

    if results is not an integer and (results < 1 or results > 6) then put 6 into results
    put sColor into tOldColor

    tinycolor pColor
    put toHsv() into hsv
    _objectToArray hsv

    put hsv["h"] into h
    put hsv["s"] into s
    put hsv["v"] into v
    put 1 / results into modification

    local index = 0
    repeat with i = results down to 1
        add 1 to index
        tinyColor ("{ h: " & h," s: " & s," v: " & v & " }")
        put toRgb(true) into ret[ index ]
        put (v + modification) mod 1 into v
    end repeat

    put tOldColor into sColor
    return ret
end monochromatic



// Utility Functions
// ---------------------
function tinycolor.mix color1, color2, amount
    local rgb1, rgb2, p, rgba
    -- amount = (amount === 0) ? 0 : (amount || 50);
    if amount is empty then put 50 into amount
    get tinycolor(color1)
    put toRgb() into rgb1
    _objectToArray rgb1
    get tinycolor(color2)
    put toRgb() into rgb2
    _objectToArray rgb2
    put amount / 100 into p
    put "{ r:" && ((rgb2["r"] - rgb1["r"]) * p) + rgb1["r"]," g: " & ((rgb2["g"] - rgb1["g"]) * p) + rgb1["g"]," b: " & ((rgb2["b"] - rgb1["b"]) * p) + rgb1["b"]," a:" && ((rgb2["a"] - rgb1["a"]) * p) + rgb1["a"] && "}" into rgba
    return tinycolor(rgba);
end tinycolor.mix

// Readability Functions
// ---------------------
// <http://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef (WCAG Version 2)

// `contrast`
// Analyze the 2 colors and returns the color contrast defined by (WCAG Version 2)
function tinycolor.readability color1, color2
    local c1, c2, l1, l2
    put tinycolor(color1) into c1
    put getLuminance() into l1
    put tinycolor(color2) into c2
    put getLuminance() into l2
    return (max(l1,l2) + 0.05) / (min(l1,l2) + 0.05);
end tinycolor.readability


// `isReadable`
// Ensure that foreground and background color combinations meet WCAG2 guidelines.
// The third argument is an optional Object.
//      the 'level' property states 'AA' or 'AAA' - if missing or invalid, it defaults to 'AA';
//      the 'size' property states 'large' or 'small' - if missing or invalid, it defaults to 'small'.
// If the entire object is absent, isReadable defaults to {level:"AA",size:"small"}.

// *Example*
//    tinycolor.isReadable("#000", "#111") => false
//    tinycolor.isReadable("#000", "#111",{level:"AA",size:"large"}) => false
function tinycolor.isReadable color1, color2, wcag2
    local readability, wcag2Parms,  tOut = false
    put tinycolor.readability(color1, color2) into readability
    put validateWCAG2Parms(wcag2) into wcag2Parms

    switch (wcag2Parms["level"] + wcag2Parms["size"])
        case "AAsmall"
        case "AAAlarge"
            put readability >= 4.5 into tOut
            break
        case "AAlarge"
            put readability >= 3 into tOut
            break
        case "AAAsmall"
            put readability >= 7 into tOut
            break
    end switch
    return tOut
end tinycolor.isReadable


// `mostReadable`
// Given a base color and a list of possible foreground or background
// colors for that base, returns the most readable color.
// Optionally returns Black or White if the most readable color is unreadable.
// *Example*
//    mostReadable(mostReadable("#123", ["#124", "#125"],{includeFallbackColors:false});toHexString(); // "#112255"
//    mostReadable(mostReadable("#123", ["#124", "#125"],{includeFallbackColors:true});toHexString();  // "#ffffff"
//    mostReadable("#a8015a", ["#faf3f3"],{includeFallbackColors:true,level:"AAA",size:"large"});toHexString(); // "#faf3f3"
//    mostReadable("#a8015a", ["#faf3f3"],{includeFallbackColors:true,level:"AAA",size:"small"});toHexString(); // "#ffffff"
function  mostReadable baseColor, colorList, args
    local bestColor = "", bestScore = 0, readability, includeFallbackColors, tLevel, tSize, tLength
    if args is empty then put "{}" into args
    _objectToArray args

    put quote & args["includeFallbackColors"] & quote into includeFallbackColors
    put quote &  args["level"] & quote  into tLevel
    put quote &  args["size"] & quote  into tSize

    put the number of elements of colorList into tLength
    repeat with i = 1 to tLength
        put tinyColor.readability(baseColor, colorList[i]) into readability
        if readability > bestScore then
            put readability into bestScore
            put tinycolor( colorList[i] ) into bestColor
        end if
    end repeat

    local tColor
    if tinycolor.isReadable(baseColor, bestColor, ("{" & quote & "level" & quote & ": " & tLevel, quote & "size" & quote &  ": " & tSize & " }")) or not includeFallbackColors then
        put sColor into tColor
        tinyColor bestColor
        put toRgb(true) into bestColor
        put tColor into sColor

    else
        put false into args["includeFallbackColors"]
        put ArrayToJson(args) into args
        put "#fff" into colorList[1]
        put "#000" into colorList[2]
        put sColor into tColor
        tinyColor mostReadable(baseColor, colorList, args);
        put toRgb(true) into bestColor
        put tColor into sColor
    end if

    return bestColor
end mostReadable




// Utilities
// ---------
// Return a valid alpha value [0,1] with all invalid values being set to 1
function boundAlpha pA
    put parseFloat(pA) into pA
    if isNaN(pA) or pA < 0 or pA > 1 then
        put 1 into pA
    end if
    return pA
end boundAlpha


// Take input from [0, n] and return it as [0, 1]
function bound01 n, pMax
    local processPercent
    if isOnePointZero(n) then put "100%" into n

    put isPercentage(n) into processPercent
    put min(pMax, max(0, parseFloat(n))) into n

    // Automatically convert percentage into number
    if processPercent is true then
        put  parseInt(n * pMax, 10)/ 100 into n
    end if

    // Handle floating point rounding errors
    if abs(n - pMax) < 0.000001 then
        return 1
    end if

    // Convert into [0, 1] range if it isn't already
    return (n mod pMax) / parseFloat(pMax)
end bound01

// Force a number between 0 and 1
function clamp01 val
  return min(1, max(0, val))
end clamp01

// Parse a base-16 hex value into a base-10 integer
function parseIntFromHex val
   return parseInt(val, 16)
end parseIntFromHex


// Need to handle 1.0 as 100%, since once it is a number, there is no difference between it and 1
function isOnePointZero n
   return n begins with "1.0" and the length of n is 3
end isOnePointZero


// Check to see if string passed in is a percentage
function isPercentage n
  return n ends with "%"
end isPercentage


// Force a hex value to have 2 characters
function pad2 c
    if the length of c is 1 then return 0 & c
    else return c
end pad2


// Replace a decimal with it's percentage value
function convertToPercentage n
    if "%" is in n  then replace "%" with "" in n
    if n <= 1 then
        put (n * 100) into n
    end if
    return n  & "%"
end convertToPercentage


// Converts a decimal to a hex value
function convertDecimalToHex d
    return baseConvert(round(parseFloat(d) * 255),10,16)
end convertDecimalToHex


// Converts a hex value to a decimal
function convertHexToDecimal h
    return parseIntFromHex(h) / 255
end convertHexToDecimal


// `isValidCSSUnit`
// Take in a single string / number and check to see if it looks like a CSS unit
function isValidCSSUnit pValue
    replace space with "" in pValue
    if pValue ends with "%" then
        delete last char of pValue
    end if
    return pValue is a number and pValue is not among the lines of constantNames() for value
end isValidCSSUnit


// `stringInputToObject`
// Permissive string parsing. Take in a number of formats, and output an object
// based on detected format. Returns `{ r, g, b }` or `{ h, s, l }` or `{ h, s, v}`
function stringInputToObject pString
    local tType, tNewString, tNum
    put word 1 to - 1 of pString into pString
    if "(" is in pString then replace "(" with " " in pString
    if ")" is in pString then replace ")" with "" in pString
    if "," is in pString then replace "," with " " in pString
    put word 1 of pString into tType
    put word 2 to - 1 of pString into pString

    if tType is empty  then
        return empty
    end if

    if tType is among the items of "rgb,rgba,hsl,hsv,hsla" then
        put the number of chars of tType into tNum

        repeat with x = 1 to tNum
            if tNum is x then
                put the char x of tType &": "& the word x of pString  after tNewString
            else
                put the char x of tType &": "& the word x of pString & ", " after tNewString
            end if
        end repeat
        return "{ " & tNewString & " }"  for value
    else
        return empty for value
    end if
end stringInputToObject


function validateWCAG2Parms parms
    // return valid WCAG2 parms for isReadable.
    // If input parms are invalid, return {"level":"AA", "size":"small"}
    local tlevel, tsize
    if parms is empty then
        put "{" & quote & "level" & quote & ":" & quote & "AA",  quote & "size" & quote & ":" & quote & "small" & quote & "}" into parms
    end if

    put JsonToArray(parms) into parms
    if parms["level"] is empty then
        put "AA" into parms["level"]
    end if
    put toUpper(parms["level"]) into parms["level"]

    if parms["size"] is empty then
        put "small" into tsize
    end if
    put toLower(tsize) into tsize

    if tlevel <> "AA" and tlevel <> "AAA" then
        put "AA" into tlevel
    end if
    if tsize <> "small" and tsize <> "large" then
        put "small" into tsize
    end if

    return "{" & quote & "level"  & quote & ":" & quote & "level",  quote & "size" & quote & ":" & size &" }"
end validateWCAG2Parms


function RgbToRgbString r, g, b
    local tRgb
    put r, g, b  into tRgb
    split tRgb by comma

    return "rgb " & tRgb[1] && tRgb[2] && tRgb[3]

end RgbToRgbString

### ON Utilities ###
private function _fixRGB pRGB
    local rgb

    if pRGB is not empty then
        split pRGB by comma
        put _fixRgbValue(pRGB[1]) into item 1 of rgb
        put _fixRgbValue(pRGB[2]) into item 2 of rgb
        put _fixRgbValue(pRGB[3]) into item 3 of rgb
        if pRGB[4] is a integer then
            put _fixRgbValue(pRGB[4]) into item 4 of rgb
        end if
    else if sColor is a array then
        put sColor["r"] into item 1 of rgb
        put sColor["g"] into item 2 of rgb
        put sColor["b"] into item 3 of rgb
        if sColor["a"] is a integer then
            put sColor["a"] into item 4 of rgb
        end if
    end if

    return rgb for value
end _fixRGB

private function _fixRgbValue pValue
    return min(255,max(0, pValue))
end _fixRgbValue

// Evalua los tipos de datos de una variable
// number, string, boolean, object, array y undefined
private function typeof p
    switch
        case p is strictly a string and p is not a number
            if word 1 of p begins with "{" and  word -1 of  p ends with "}"  then
                return "object"
            else
                return "string"
            end if
        break

        case p is a array
            return "array"
        break

        case p is a number
            return "number"
        break

        case p is true or p is false
            return "boolean"
        break

        default
        return "undefined"
    end switch
end typeof


function getRgbFromColor pColor
    local tColorRGB
    if pColor is a color then
        set the colorOverlay["color"] of the templateGraphic to pColor
        put the colorOverlay["color"] of the templateGraphic into tColorRGB
        reset the templateGraphic
    end if
    return tColorRGB  for value
end getRgbFromColor


private function isHex x
    if char 1 x is "#" then delete char 1 of x
    if the length of x is not in "3 6 8" then return false

    repeat for each char c in x
        if c is not in "0123456789ABCDEFabcdef" then
            return false for value
            exit repeat
        end if
    end repeat
    return true for value
end isHex


private command _objectToArray @pObj
    local tArray
    if char 1 of word 1 of pObj is "{" then delete char 1 of word 1 of pObj
    if char -1 of word -1 of pObj is "}" then delete char -1 of word -1 of pObj
    put word 1 to - 1 of pObj into pObj
    replace ", " with "," in pObj
    split pObj by comma and ":"
    return pObj for value
end _objectToArray


private function toFixed n,fix
    set the itemdel to "."
    if fix is not a integer then return trunc( n )
    if fix is 0 or item 2 of n is empty then return trunc( n )
    else return the item 1 of n & "." & the char 0 to fix of item 2 of n for value
end toFixed


private function parseInt pNum,pOriginalBase
   if pOriginalBase is empty then put 10 into pOriginalBase
   try
      return trunc(baseConvert( trunc(pNum),pOriginalBase,10)) for value
   catch tError
      return "Error in parseInt"  for value
   end try
end parseInt

private function parseFloat pString
    local tFloat, d = 0
    replace space with "" in pString
    repeat for each char c in pString
        if c is "." then add 1 to d
        if c is not in "+-.0123456789" or d > 1 then exit repeat
        put c after tFloat
    end repeat
    if "." is not in tFloat then return tFloat
    return tFloat
end parseFloat

private function isNaN n
    return n is not a number and n is among the lines of the constantNames for value
end isNaN

private function _rightShift pNum, pOff
    if pNum >= 0 then
        return trunc( pNum /(2^ pOff ))
    else
        return  round( (pNum - 1) /(2 ^ pOff ))
    end if
end _rightShift

### END Utilities ###
