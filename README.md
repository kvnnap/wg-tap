# wg-tap

Passes L2 traffic through wireguard using gretap. Due to the limitations in the *unshare* executable, signalling is used to keep namespace alive. Unshare supports binding namespaces but it must be run as root, and this messes with some namespaces. My requirement is to run the "container" as the current user (not root).

## Use

The start script sets up everything. Currently some variables are hard coded.

`./start.sh`

## Executing smaller scripts

if calling add-br.sh and del.br.sh manually, run `sudo service dhcpcd stop` beforehand.

## Notes

See start.sh to understand what is going on.

also see https://github.com/swetland/mkbox

Using mkbox above would probably make the process of setting up the "container" much easier.

enter "container" using:

`nsenter --preserve-credentials -t <pid> -U -m -p -n /bin/ash`

use `lsns` to easily identify the pid


