# Cloud HAP signing

The GitHub Actions workflow always produces a signed HAP:

- With no signing secrets, it uses the public OpenHarmony SDK test key. That
  package is intended for OpenHarmony development devices/images that trust the
  public test key.
- When all six secrets below are present, it uses the supplied Huawei developer
  material and produces a package suitable for the devices covered by that
  signing profile.

Configure these repository Actions secrets:

| Secret | Value |
| --- | --- |
| `HAP_SIGNING_P12_B64` | Base64-encoded `.p12` keystore |
| `HAP_SIGNING_CERT_B64` | Base64-encoded application `.cer` certificate |
| `HAP_SIGNING_PROFILE_B64` | Base64-encoded signed `.p7b` profile |
| `HAP_KEY_ALIAS` | Keystore key alias |
| `HAP_KEY_PASSWORD` | Private-key password |
| `HAP_STORE_PASSWORD` | Keystore password |

All six values must be configured together. A partial configuration deliberately
fails instead of silently publishing a test-signed package.
