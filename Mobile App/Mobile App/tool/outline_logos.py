"""Regenerate portable logo paths using the bundled open-source font."""
import sys
sys.path.insert(0,'/tmp/herly-font-tools')
from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
root=Path(__file__).resolve().parent.parent

def lettering(text,font_path,size,x,y,spacing=0):
    font=TTFont(font_path); glyphs=font.getGlyphSet(); cmap=font.getBestCmap(); scale=size/font['head'].unitsPerEm
    widths=[font['hmtx'][cmap[ord(c)]][0]*scale+spacing for c in text]
    cursor=x-sum(widths)/2
    paths=[]
    for char,width in zip(text,widths):
        pen=SVGPathPen(glyphs);glyphs[cmap[ord(char)]].draw(pen)
        paths.append(f'<path transform="translate({cursor} {y}) scale({scale} {-scale})" d="{pen.getCommands()}"/>');cursor+=width
    return ''.join(paths)
petals=(root/'assets/brand/symbol.svg').read_text().split('>',1)[1].rsplit('</svg>',1)[0]
for name,color in [('logo','#C43366'),('logo-dark','#FFF9F5'),('logo-mono','#4A1D3C')]:
    body=f'<g transform="translate(139 -5) scale(.65)">{petals}</g>'
    body+=f'<g fill="{color}">'+lettering('Herly',root/'assets/fonts/DeliusSwashCaps-Regular.ttf',124,180,162)+lettering('Her Life. Her Way.',root/'assets/fonts/Manrope.ttf',16,180,201,2)+'</g>'
    (root/f'assets/brand/{name}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 360 216">{body}</svg>')
