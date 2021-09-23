# RandomDotOrg.jl

Julia module with functions to provide support for obtaining random numbers generated by the <a href="https://random.org">RANDOM.ORG (RDO)</a> website using HTTP. Freely adapted and extended from the random package in R, written by Dirk Eddelbuettel <edd@debian.org>. To obtain slightly faster responses, try the RDO API using the functions at the following repository: https://github.com/edwcarney/RandomDotOrgAPI.jl

From the RANDOM.ORG <a href="https://www.random.org/faq">FAQ (Q4.1)</a>:
<blockquote>The RANDOM.ORG setup uses an array of radios that pick up atmospheric noise. Each radio generates approximately 12,000 bits per second. The random bits produced by the radios are used as the raw material for all the different generators you see on RANDOM.ORG. Each time you use one of the generators, you spend some bits. By enforcing a limit on the number of bits you can use per day, the quota system prevents any one person from hogging all the numbers. (Believe us, this was a big problem before we implemented the quota system.)</blockquote>

# Current functions
<b>get_quota()</b>&mdash;obtain current bit quota for your IP<br>
<b>check_quota()</b>&mdash;check if quota is non-zero<br>
<b>random_numbers()</b>&mdash;obtain integers<br>
<b>random_sequence()</b>&mdash;obtain randomized sequences of integers 1..N<br>
<b>random_strings()</b>&mdash;obtain random strings of characters (upper/lower case letters, digits)<br>
<b>random_gaussian()</b>&mdash;obtain random Gaussian numbers<br>
<b>random_decimal_fractions()</b>&mdash;obtain random numbers on the interval (0,1)<br>
<b>random_bytes()</b>&mdash;obtain random bytes in various formats<br>
<b>random_bitmap()</b>&mdash;obtain a random bitmap of size up to 300 x 300 as GIF or PNG<br>

Simply include the file with <b>include("RandomDotOrg.jl")</b>. You may also place the package files in a folder entitled RandomDotOrg and add the folder to your Julia LOAD_PATH. See <a href="https://en.wikibooks.org/wiki/Introducing_Julia/Modules_and_packages#How_does_Julia_find_a_module?">here</a> for information on custom modules.

Values are returned in vector arrays of integers or strings.

The use of secure HTTP by RANDOM.ORG prevents interception while the numbers are in transit. However, it is probably best not to use the Random.org site for any purpose that might have a direct impact on security. The FAQ (Q2.4) on the website says the following: "We should probably note that while fetching the numbers via secure HTTP would protect them from being observed while in transit, anyone genuinely concerned with security should not trust anyone else (including RANDOM.ORG) to generate their cryptographic keys."

using HTTP, Printf
