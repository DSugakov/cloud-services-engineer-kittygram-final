import re; f = open('cats/serializers.py', 'r'); content = f.read(); f.close(); content = re.sub(r"representation\['image'\] = 'http://localhost:9000/media/' \+ str\(instance.image\)", r"representation['image'] = '/media/' + str(instance.image)", content); f = open('cats/serializers.py', 'w'); f.write(content); f.close(); print('File updated')
