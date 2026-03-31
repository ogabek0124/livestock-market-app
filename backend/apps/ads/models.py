from django.db import models
from django.conf import settings
from apps.categories.models import Category

class Ad(models.Model):
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('sold', 'Sold'),
        ('pending', 'Pending')
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='ads')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, related_name='ads')
    title = models.CharField(max_length=255)
    description = models.TextField()
    price = models.DecimalField(max_digits=12, decimal_places=2)
    
    city = models.CharField(max_length=100)
    region = models.CharField(max_length=100)
    
    image = models.ImageField(upload_to='ads/', blank=True, null=True)
    
    views = models.IntegerField(default=0)
    is_top = models.BooleanField(default=False)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='active')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    expires_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return self.title
