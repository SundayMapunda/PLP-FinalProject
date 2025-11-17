from django.contrib.auth import get_user_model
from rest_framework import serializers

from .models import Item


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = get_user_model()
        fields = ("id", "username", "email", "bio", "location")


class ItemSerializer(serializers.ModelSerializer):
    owner = UserSerializer(read_only=True)  # Read-only, set by the view

    class Meta:
        model = Item
        fields = "__all__"
