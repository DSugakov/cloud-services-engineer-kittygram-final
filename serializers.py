import base64
import datetime as dt

import webcolors
from django.core.files.base import ContentFile
from rest_framework import serializers
from django.conf import settings

from .models import Achievement, AchievementCat, Cat


class Hex2NameColor(serializers.Field):
    def to_representation(self, value):
        try:
            return webcolors.hex_to_name(value)
        except ValueError:
            return value

    def to_internal_value(self, data):
        try:
            data = webcolors.name_to_hex(data)
        except ValueError:
            pass
        return data


class AchievementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Achievement
        fields = ('id', 'name')


class Base64ImageField(serializers.ImageField):
    def to_internal_value(self, data):
        if isinstance(data, str) and data.startswith('data:image'):
            format, imgstr = data.split(';base64,')
            ext = format.split('/')[-1]
            data = ContentFile(base64.b64decode(imgstr), name='temp.' + ext)
        return super().to_internal_value(data)


class CatSerializer(serializers.ModelSerializer):
    achievements = AchievementSerializer(many=True, required=False)
    color = Hex2NameColor()
    age = serializers.SerializerMethodField()
    image = Base64ImageField(required=False, allow_null=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Cat
        fields = (
            'id', 'name', 'color', 'birth_year', 'achievements',
            'owner', 'age', 'image', 'image_url'
        )
        read_only_fields = ('owner',)

    def get_image_url(self, obj):
        if obj.image:
            return obj.image.url
        return None

    def get_age(self, obj):
        if obj.birth_year:
            return dt.datetime.now().year - obj.birth_year
        return None

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        if representation.get('image') and not representation.get('image').startswith('http'):
            if representation.get('image').startswith('/'):
                representation['image'] = representation['image']
            else:
                representation['image'] = '/' + representation['image']
        return representation

    def create(self, validated_data):
        if 'achievements' not in self.initial_data:
            cat = Cat.objects.create(**validated_data)
            return cat
        achievements = validated_data.pop('achievements')
        cat = Cat.objects.create(**validated_data)
        for achievement in achievements:
            current_achievement, status = Achievement.objects.get_or_create(
                **achievement
            )
            AchievementCat.objects.create(
                achievement=current_achievement, cat=cat
            )
        return cat

    def update(self, instance, validated_data):
        instance.name = validated_data.get('name', instance.name)
        instance.color = validated_data.get('color', instance.color)
        instance.birth_year = validated_data.get(
            'birth_year', instance.birth_year
        )
        instance.image = validated_data.get('image', instance.image)

        if 'achievements' not in validated_data:
            instance.save()
            return instance

        achievements_data = validated_data.pop('achievements')
        lst = []
        for achievement in achievements_data:
            current_achievement, status = Achievement.objects.get_or_create(
                **achievement
            )
            lst.append(current_achievement)
        instance.achievements.set(lst)

        instance.save()
        return instance 