"""
    RandomDotOrg

Use various functions from https://random.org (q.v.).

# Currently available
- getQuota(): obtain current bit quota for your IP.
- checkQuota(): check if quota is non-zero.
- random_numbers(): obtain integers.
- random_sequences(): obtain randomized sequences of integers 1..N
- random_strings(): obtain random strings of characters (upper/lower case letters, digits)
- random_gaussian(): obtain random Gaussian numbers
- random_decimal_fractions(): obtain random numbers on the interval (0,1)
- random_bytes(): obtain random bytes in various formats
- random_bitmap(): obtain a random bitmap of size up to 300 x 300 as GIF or PNG.

Github repository at: https://github.com/edwcarney/RandomDotOrg

"""
module RandomDotOrg

using HTTP, Printf
export  getQuota, checkQuota, random_numbers, random_sequences, random_strings, random_gaussian,
        random_decimal_fractions, random_bytes, random_bitmap

"""
    Get the current bit quota from Random.org
"""
function getQuota()
    r = HTTP.get("https://www.random.org/quota/?format=plain");
    return parse(Int64, rstrip(String(r.body)))
end;

"""

    checkQuota(minimum = 500::Number)

    Test for sufficient quota to insure response. This should be set to match
    user's needs.
"""
function checkQuota(minimum = 500::Number)
    return getQuota() >= minimum
end;

"""

    random_numbers(n = 100::Number, min = 1, max = 20, base = 10, parse=true, check = true, col = 5) 
 
Get `n` random integers on the interval `[min, max]` as strings
in one of 4 `base` values--[binary (2), octal (8), decimal (10), or hexadecimal (16)]
All numbers are returned as strings (as Random.org sends them).

# Arguments
- `max`,`min` : [-1e9, 1e9]
- `base::Integer`: retrieved Integer format [2, 8, 10, 16]
- `numeric`: return numbers instead of strings (base = 10, only)
- `check::Bool`: perform a call to `checkQuota` before making request
- `col::Integer`: used to fulfill parameter requirments of random.org

# Examples
```
julia> random_numbers(5, max=50, base=16)
5-element Array{SubString{String},1}:
 "1f"
 "27"
 "12"
 "05"
 "2c"

julia> random_numbers(5, max=4096, base=2, min=2048)
5-element Array{SubString{String},1}:
 "0110011101101"
 "0110101001011"
 "0100101001110"
 "0101000001110"
 "0101101101100"

julia> random_numbers(5, max=200)
5-element Array{Int64,1}:
  69
 107
  69
 155
  72

julia> random_numbers(5, max=200, numeric=false)
5-element Array{SubString{String},1}:
 "121"
 "178"
 "155"
 "12" 
 "71"
```
"""
function random_numbers(n = 100::Number; min = 1, max = 20, base = 10, numeric = true, check = true, col = 5) 
    (n < 1 || n > 10000) && return "Requests must be between 1 and 10,000 numbers"

    (min < -1f+09 || max > 1f+09 || min > max) && return "Range must be between -1e9 and 1e9"

    (!(base in [2, 8, 10, 16])) && return "Base has to be one of 2, 8, 10 or 16"

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    urlbase = "https://www.random.org/integers/"
    urltxt = @sprintf("%s?num=%d&min=%d&max=%d&col=%d&base=%d&format=plain&rnd=new",
                    urlbase, n, Int(min), Int(max), col, base)
    response = HTTP.get(urltxt)
    (numeric && base == 10) && return [parse(Int, x) for x in split(rstrip(String(response.body)))]
    return split(rstrip(String(response.body)))
end;

"""
Get a randomized interval `[min, max]`. Returns (max - min + 1) randomized integers
All numbers are returned as strings (as Random.org sends them).

# Arguments
- `min` : no less than 1
- `max` : must be [-1e9, 1e9]
- `col::Integer` : used to fulfill parameter requirments of random.org
- `check::Bool`: perform a call to `checkQuota` before making request

# Example
```
julia> random_sequences(max=8)
8-element Array{Int64,1}:
 4
 1
 5
 3
 6
 7
 8
 2
```
"""
function random_sequences(;min = 1::Number, max = 20::Number, col = 1, check = true)
    (min < -1f+09 || max > 1f+09 || min > max) && return "Range must be between -1e9 and 1e9"

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"
 
    urlbase = "https://www.random.org/sequences/"
    urltxt = @sprintf("%s?min=%d&max=%d&col=%d&format=plain&rnd=new",
                    urlbase, Int(min), Int(max), col)
    response = HTTP.get( urltxt)
    return [parse(Int64, x) for x in split(rstrip(String(response.body)))]
end;

"""

    random_strings(n=10::Number, len=5; digits=true, upperalpha=true, loweralpha=true, unique=true, check=true)

Get `n` random strings of length `len`

# Arguments
- `len` : length of strings [1, 20]
- `digits::Bool`: include digits in strings
- `upperalpha::Bool`: include upper case letters in strings
- `loweralpha::Bool`: include lowercase letters in strings
- `unique::Bool`: strings must be unique if `true`
- `check::Bool`: perform a call to `checkQuota` before making request

# Examples
```
julia> random_strings(5, 8, loweralpha=false)
5-element Array{SubString{String},1}:
 "8LPPSHYL"
 "Y3I7ILXJ"
 "0O9C41EK"
 "Y2N7U9WZ"
 "OH9EZ3ST"

julia> random_strings(3, 4, digits=false)
3-element Array{SubString{String},1}:
 "cKIG"
 "HUir"
 "gAzX" 
```
"""
function random_strings(n=10::Number, len=5; digits=true, upperalpha=true, loweralpha=true, unique=true, check=true)
    (n < 1 || n > 10000) && return "1 to 10,000 requests only"

    (len < 1 || len > 20) && return "Length must be between 1 and 20"

    (typeof(digits) != Bool || typeof(upperalpha) != Bool || typeof(loweralpha) != Bool || typeof(unique) != Bool) && return "The 'digits', '(lower|upper)alpha' and 'unique' arguments have to be logical"

    (!digits && !upperalpha && !loweralpha) && return "The 'digits', 'loweralpha' and 'upperalpha' cannot all be false"

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    urlbase = "https://www.random.org/strings/"
    urltxt = @sprintf("%s?num=%d&len=%d&digits=%s&upperalpha=%s&loweralpha=%s&unique=%s&format=plain&rnd=new",
                urlbase, n, len, ifelse(digits, "on", "off"),
                ifelse(upperalpha, "on", "off"), ifelse(loweralpha, "on", "off"),
                ifelse(unique, "on", "off"))
    response = HTTP.get( urltxt)
    split(rstrip(String(response.body)))
end;

"""

    random_gaussian(n=10::Number, mean=0.0, stdev=1.0; dec=10, col=1, notation="scientific", check=true)

Get n numbers from a Gaussian distribution with `mean` and `stdev`.
Returns strings in `dec` decimal places.
Scientific notation only for now.

# Arguments
- `mean`, `stdev` : between [-1e6, 1e6]
- `dec` : decimal places [2,20]
- `col` : unique value
- `scientific` : unique value
- `check::Bool`: perform a call to `checkQuota` before making request

# Example
```
julia> random_gaussian(5, dec=5)
5-element Array{Float64,1}:
 -0.36174
  0.95992
  1.2278 
  1.0429 
  0.31885
```
"""
function random_gaussian(n=10::Number, mean=0.0, stdev=1.0; dec=10, col=1, notation="scientific", check=true)
    (n < 1 || n > 10000) && return "Requests must be between 1 and 10,000 numbers"

    (mean < -1f+06 || mean > 1f+06) && return "Mean must be between -1e6 and 1e6"

    (stdev < -1f+06 || stdev > 1f+06) && return "Std dev must be between -1e6 and 1e6"

    (dec < 2 || dec > 20) && return "Decimal places must be between 2 and 20"

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    urlbase = "https://www.random.org/gaussian-distributions/"
    urltxt = @sprintf("%s?num=%d&mean=%f&stdev=%f&dec=%d&col=%d&notation=%s&format=plain&rnd=new",
                    urlbase, n, mean, stdev, dec, col, notation)
    # print(urltxt)
    response = HTTP.get( urltxt)
    return [parse(Float64, x) for x in split(rstrip(String(response.body)))]
end;

"""
    random_decimal_fractions(n=10::Number; dec=10, col=2, check=true)

Get n decimal fractions on the interval (0,1).
Returns strings in `dec` decimal places.

# Arguments
- `dec` : decimal places [2, 20]
- `col` : unique value
- `check::Bool`: perform a call to `checkQuota` before making request

# Example
```
julia> random_decimal_fractions(5, dec=3)
5-element Array{Float64,1}:
 0.788
 0.949
 0.773
 0.875
 0.552
```
"""
function random_decimal_fractions(n=10::Number; dec=10, col=2, check=true)
    (n < 1 || n > 10000) && return "Requests must be between 1 and 10,000 numbers"

    (dec < 2 || dec > 20) && return "Decimal places must be between 2 and 20"

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    urlbase = "https://www.random.org/decimal-fractions/"
    urltxt = @sprintf("%s?num=%d&dec=%d&col=%d&format=plain&rnd=new",
                        urlbase, n, dec, col)
    # print(urltxt)
    response = HTTP.get( urltxt)
    return [parse(Float64, x) for x in split(rstrip(String(response.body)))]
end;

"""
    random_bytes(n=10::Number; format="o", check=true)

Get n random bytes.
Returns strings in binary, decimal, octal, or hexadecimal.
The request will also download a DMS file.

# Arguments
- `format` : format of bytes; one of b, d, o, h, or file (Int in hex)
- `check::Bool`: perform a call to `checkQuota` before making request

# Examples
```
julia> random_bytes(5, format='o')
5-element Array{SubString{String},1}:
 "075"
 "030"
 "317"
 "277"
 "356

julia> random_bytes(5, format="file")
5-element Array{UInt8,1}:
 0xda
 0xdf
 0xd9
 0xb3
 0x97
```
"""
function random_bytes(n=10::Number; format='o', check=true)
    (n < 1 || n > 10000) && return "Requests must be between 1 and 10,000 numbers"

    (!(format in ['b', 'd', 'o', 'h', "file"])) && return "Format must be one of b, d, o, h, or file."

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    urlbase = "https://www.random.org/cgi-bin/randbyte"
    urltxt = @sprintf("%s?nbytes=%d&format=%s",
                        urlbase, n, format)
    # print(urltxt)
    # response = HTTP.get( urltxt)
    response = HTTP.get(urltxt)
    if (format == "file")
        return response.body
    else 
        return split(rstrip(String(response.body)))
    end
end

"""
    random_bitmap([format="png"; width=64, height=64, save="", overwrite='n', check=true])

Get a random bitmap as a PNG or GIF.

# Arguments
- `format::String`: png or gif
- `height, width`: 1-300 pixels in each dimension
- `save`: filename/filepath to write file (extension added by default)
- `overwrite`: will not overwrite by default; set to 'y' to overwrite
- `check::Bool`: perform a call to `checkQuota` before making request

"""
function random_bitmap(format="png"; width=64, height=64, save="", overwrite='n', check=true)
    (!(format in ["png", "gif"])) && return "Format must be png or gif."

    (width < 1 || width > 300 || height < 1 || height > 300) && return "Height/Width must be no more than 300."

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    full_path = @sprintf("%s.%s", save, format)
    (isfile(full_path) && overwrite=='n') && return @sprintf("File %s exists. Set overwrite to 'y' to save.", full_path)

    urlbase = "https://www.random.org/bitmaps"
    urltxt = @sprintf("%s?format=%s&height=%d&width=%d&zoom=1",
                        urlbase, format, height, width)
    response = HTTP.get(urltxt)
    if save == ""
        return(response.body)
    else
        # full_path = @sprintf("%s.%s", save, format)
        # if isfile(full_path) && overwrite == 'n'
        #     @printf("File not saved; %s exists. Set overwrite to \"y\".", full_path)
        # else
        open(full_path, "w") do outfile
            write(outfile, response.body)
        end
        @printf("File saved as: %s\n", full_path)
    # end
    end
end

end;  # module
