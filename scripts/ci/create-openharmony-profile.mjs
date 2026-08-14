import { randomUUID } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';

const [templatePath, outputPath, bundleName] = process.argv.slice(2);

if (!templatePath || !outputPath || !bundleName) {
  console.error(
    'Usage: node create-openharmony-profile.mjs <template> <output> <bundle-name>',
  );
  process.exit(2);
}

const profile = JSON.parse(await readFile(templatePath, 'utf8'));
const now = Math.floor(Date.now() / 1000);

profile.uuid = randomUUID();
profile.validity = {
  'not-before': now - 300,
  // Stay inside the bundled OpenHarmony root certificate validity (2049-12-31).
  'not-after': Math.min(now + 10 * 365 * 24 * 60 * 60, 2524521600),
};
profile.type = 'release';
profile['bundle-info']['bundle-name'] = bundleName;
profile['bundle-info'].apl = 'normal';
profile['bundle-info']['app-feature'] = 'hos_normal_app';
profile.acls = { 'allowed-acls': [] };
profile.permissions = { 'restricted-permissions': [] };

await writeFile(outputPath, `${JSON.stringify(profile, null, 2)}\n`, {
  mode: 0o600,
});
