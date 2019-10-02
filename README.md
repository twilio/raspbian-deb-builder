# Debian package builder for Twilio Broadband DebKit Image

Builds Twilio flavor of Azure IoT C SDK and Twilio's Trust Onboard SDK in a debootstrap environment. Build machine is assumed to be debian-compatible.

## Technical debt
  * Azure SDK version is hardcoded in the `changelog` to `1.0.0`, distro is hardcoded to `buster`. At least `changelog` should be generated dynamically.
  * Ideally ready-made `debian` repository should not be used at all, `dh-make` should be enough.
  * If we build Trust Onboard SDK with `dh-make` as well, we can have unified build process for both (and whatever we need to install in future).
  * Packages are not being signed
