from PIL import Image
src='apple-touch-icon.png'
try:
    im = Image.open(src)
except Exception as e:
    raise SystemExit('Cannot open source image: '+str(e))
# ensure square by cropping center
w,h=im.size
minside=min(w,h)
left=(w-minside)//2
top=(h-minside)//2
im2=im.crop((left,top,left+minside,top+minside)).convert('RGBA')
sizes=[16,32,48,64]
icons=[]
for s in sizes:
    icons.append(im2.resize((s,s), Image.LANCZOS))
# save ico
im2.save('favicon.ico', format='ICO', sizes=[(s,s) for s in sizes])
print('favicon.ico created with sizes:',sizes)
