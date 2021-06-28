from PIL import Image

img_name = input()
img = Image.open(img_name)
mask = Image.new("L", img.size)

for x in range(img.width):
    for y in range(img.height):
        pixel = img.getpixel((x, y))
        if pixel != (255, 255, 255, 255) and pixel != (231, 230, 230, 255):
            mask.putpixel((x, y), 255)
        else:
            mask.putpixel((x, y), 0)

mask.save("result.png")