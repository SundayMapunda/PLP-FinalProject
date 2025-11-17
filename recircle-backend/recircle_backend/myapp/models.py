from django.contrib.auth.models import AbstractUser
from django.db import models


class CustomUser(AbstractUser):
    # Inherits fields: username, email, first_name, last_name, password, etc.
    bio = models.TextField(max_length=500, blank=True)
    location = models.CharField(max_length=100, blank=True)
    phone_number = models.CharField(max_length=15, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.username


class Item(models.Model):
    ITEM_CATEGORIES = [
        ("TOOLS", "Tools & Garden"),
        ("BOOKS", "Books & Media"),
        ("KIDS", "Kids & Baby"),
        ("HOME", "Home & Kitchen"),
        ("ELECTRONICS", "Electronics"),
        ("SPORTS", "Sports & Outdoors"),
        ("OTHER", "Other"),
    ]
    ITEM_TYPE = [
        ("BORROW", "For Borrowing"),
        ("GIVE", "For Giving Away"),
    ]

    title = models.CharField(max_length=200)
    description = models.TextField()
    owner = models.ForeignKey(
        CustomUser, on_delete=models.CASCADE, related_name="items"
    )
    category = models.CharField(max_length=20, choices=ITEM_CATEGORIES, default="OTHER")
    item_type = models.CharField(max_length=10, choices=ITEM_TYPE, default="GIVE")
    # Using ImageField, will need Pillow library installed
    image = models.ImageField(upload_to="item_images/", blank=True, null=True)
    location = models.CharField(max_length=100)  # Simple location string for now
    is_available = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} ({self.get_item_type_display()})"
