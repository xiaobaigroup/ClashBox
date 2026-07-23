#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <unsigned-hap> <artifact-directory>" >&2
  exit 2
fi

unsigned_hap="$(realpath "$1")"
artifact_dir="$(realpath -m "$2")"
bundle_name="${HAP_BUNDLE_NAME:-org.xbgroup.clashboxLTS}"
compatible_version="${HAP_COMPATIBLE_VERSION:-17}"

test -s "$unsigned_hap"
mkdir -p "$artifact_dir"

sdk_root="${OHOS_BASE_SDK_HOME:?OHOS_BASE_SDK_HOME is not set}"
sign_lib="$sdk_root/toolchains/lib"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
test_signing_repo="https://github.com/openharmony/developtools_hapsigner.git"
test_signing_commit="89fe39fa88382723e41115d7d494422a8b7ba18b"
if [[ -x "$sign_lib/hap-sign-tool" ]]; then
  sign_command=("$sign_lib/hap-sign-tool")
elif [[ -f "$sign_lib/hap-sign-tool.jar" ]]; then
  sign_command=(java -jar "$sign_lib/hap-sign-tool.jar")
else
  echo "Cannot find hap-sign-tool under $sign_lib" >&2
  exit 1
fi

required_secret_names=(
  HAP_SIGNING_P12_B64
  HAP_SIGNING_CERT_B64
  HAP_SIGNING_PROFILE_B64
  HAP_KEY_ALIAS
  HAP_KEY_PASSWORD
  HAP_STORE_PASSWORD
)
configured_secret_count=0
for secret_name in "${required_secret_names[@]}"; do
  if [[ -n "${!secret_name:-}" ]]; then
    configured_secret_count=$((configured_secret_count + 1))
  fi
done

signing_dir="$(mktemp -d "$RUNNER_TEMP/clashbox-signing.XXXXXX")"
trap 'rm -rf "$signing_dir"' EXIT
umask 077

if [[ "$configured_secret_count" -eq "${#required_secret_names[@]}" ]]; then
  signing_mode="huawei-developer"
  output_basename="ClashBox-${GITHUB_SHA:0:12}-huawei-signed.hap"
  printf '%s' "$HAP_SIGNING_P12_B64" | base64 --decode > "$signing_dir/app.p12"
  printf '%s' "$HAP_SIGNING_CERT_B64" | base64 --decode > "$signing_dir/app.cer"
  printf '%s' "$HAP_SIGNING_PROFILE_B64" | base64 --decode > "$signing_dir/app.p7b"
  app_cert="$signing_dir/app.cer"
  profile_file="$signing_dir/app.p7b"
  keystore_file="$signing_dir/app.p12"
  key_alias="$HAP_KEY_ALIAS"
  key_password="$HAP_KEY_PASSWORD"
  store_password="$HAP_STORE_PASSWORD"
elif [[ "$configured_secret_count" -eq 0 ]]; then
  signing_mode="openharmony-test"
  output_basename="ClashBox-${GITHUB_SHA:0:12}-openharmony-test-signed.hap"

  test_signing_source="$signing_dir/developtools_hapsigner"
  git clone --quiet --no-tags "$test_signing_repo" "$test_signing_source"
  git -C "$test_signing_source" checkout --quiet "$test_signing_commit"
  if [[ "$(git -C "$test_signing_source" rev-parse HEAD)" != "$test_signing_commit" ]]; then
    echo "::error::OpenHarmony test signing source is not at the pinned commit." >&2
    exit 1
  fi
  test_signing_dist="$test_signing_source/dist"

  for signing_file in \
    OpenHarmony.p12 \
    OpenHarmonyApplication.pem \
    OpenHarmonyProfileRelease.pem; do
    if [[ ! -s "$test_signing_dist/$signing_file" ]]; then
      echo "::error::Missing OpenHarmony test signing file: $test_signing_dist/$signing_file" >&2
      exit 1
    fi
  done

  node scripts/ci/create-openharmony-profile.mjs \
    "$test_signing_dist/UnsgnedReleasedProfileTemplate.json" \
    "$signing_dir/profile.json" \
    "$bundle_name"

  "${sign_command[@]}" sign-profile \
    -mode localSign \
    -keyAlias "openharmony application profile release" \
    -keyPwd "123456" \
    -profileCertFile "$test_signing_dist/OpenHarmonyProfileRelease.pem" \
    -inFile "$signing_dir/profile.json" \
    -signAlg SHA256withECDSA \
    -keystoreFile "$test_signing_dist/OpenHarmony.p12" \
    -keystorePwd "123456" \
    -outFile "$signing_dir/profile.p7b"

  app_cert="$test_signing_dist/OpenHarmonyApplication.pem"
  profile_file="$signing_dir/profile.p7b"
  keystore_file="$test_signing_dist/OpenHarmony.p12"
  key_alias="openharmony application release"
  key_password="123456"
  store_password="123456"
else
  echo "::error::HarmonyOS signing secrets are only partially configured." >&2
  echo "Configure all six HAP_SIGNING_* / HAP_KEY_* secrets or remove all of them." >&2
  exit 1
fi

signed_hap="$artifact_dir/$output_basename"
"${sign_command[@]}" sign-app \
  -mode localSign \
  -keyAlias "$key_alias" \
  -keyPwd "$key_password" \
  -appCertFile "$app_cert" \
  -profileFile "$profile_file" \
  -profileSigned 1 \
  -inFile "$unsigned_hap" \
  -inForm zip \
  -compatibleVersion "$compatible_version" \
  -signAlg SHA256withECDSA \
  -keystoreFile "$keystore_file" \
  -keystorePwd "$store_password" \
  -signCode 1 \
  -outFile "$signed_hap"

test -s "$signed_hap"
verification_cert="$signing_dir/verified-certificate-chain.cer"
verification_profile="$signing_dir/verified-profile.p7b"
verification_log="$signing_dir/verify-app.log"
"${sign_command[@]}" verify-app \
  -inFile "$signed_hap" \
  -outCertChain "$verification_cert" \
  -outProfile "$verification_profile" 2>&1 | tee "$verification_log"

# Some hap-sign-tool releases return zero even after printing a verification
# failure. Require both the explicit success marker and the requested outputs so
# a false-positive process exit can never publish an unverified HAP.
if ! grep -Fq "verify-app success" "$verification_log"; then
  echo "::error::hap-sign-tool did not report a successful HAP verification." >&2
  exit 1
fi
for verification_output in "$verification_cert" "$verification_profile"; do
  if [[ ! -s "$verification_output" ]]; then
    echo "::error::hap-sign-tool did not create $verification_output" >&2
    exit 1
  fi
done

(
  cd "$artifact_dir"
  sha256sum "$output_basename" | tee SHA256SUMS
)

{
  echo "commit=$GITHUB_SHA"
  echo "bundle=$bundle_name"
  echo "compatible-api=$compatible_version"
  echo "signing-mode=$signing_mode"
} > "$artifact_dir/build-metadata.txt"

if [[ "$signing_mode" == "openharmony-test" ]]; then
  cat > "$artifact_dir/INSTALLATION-NOTES.txt" <<'EOF'
This HAP uses the public OpenHarmony test signing key bundled with the SDK.
It is intended for OpenHarmony development devices/images that trust that key.
Commercial HarmonyOS devices require a Huawei developer certificate, profile,
keystore, alias and passwords configured as GitHub Actions secrets.
EOF
  artifact_name="ClashBox-openharmony-test-signed-hap"
else
  artifact_name="ClashBox-huawei-signed-hap"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "hap=$signed_hap"
    echo "hap_name=$output_basename"
    echo "signing_mode=$signing_mode"
    echo "artifact_name=$artifact_name"
  } >> "$GITHUB_OUTPUT"
fi
