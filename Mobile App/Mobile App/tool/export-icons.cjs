const fs = require('fs');
const path = require('path');
const sharp = require('/Users/bee/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
(async () => {
  const svg = fs.readFileSync('assets/brand/app-icon.svg');
  for (const [density,size] of [['mdpi',48],['hdpi',72],['xhdpi',96],['xxhdpi',144],['xxxhdpi',192]]) await sharp(svg).resize(size,size).png().toFile(`android/app/src/main/res/mipmap-${density}/ic_launcher.png`);
  const dir='ios/Runner/Assets.xcassets/AppIcon.appiconset';
  const manifest=JSON.parse(fs.readFileSync(path.join(dir,'Contents.json')));
  for (const icon of manifest.images) {
    const size=Math.round(parseFloat(icon.size)*parseFloat(icon.scale));
    await sharp(svg).resize(size,size).flatten({background:'#FFF1F2'}).png().toFile(path.join(dir,icon.filename));
  }
  for (const size of [192,512]) for (const prefix of ['Icon','Icon-maskable']) await sharp(svg).resize(size,size).png().toFile(`web/icons/${prefix}-${size}.png`);
  await sharp(svg).resize(64,64).png().toFile('web/favicon.png');
  await sharp(svg).resize(1024,1024).png().toFile('assets/brand/app-icon-1024.png');
})();
