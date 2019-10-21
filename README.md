# Debian package builder for Twilio Broadband DebKit Image

Builds Twilio flavor of Azure IoT C SDK and Twilio's Trust Onboard SDK in a debootstrap environment. Build machine is assumed to be debian-compatible.

## Technical debt
  * If we build Trust Onboard SDK with `dh-make` as well, we can have unified build process for both (and whatever we need to install in future).
