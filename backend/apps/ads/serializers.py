from rest_framework import serializers
from .models import Ad
from apps.users.serializers import UserSerializer
from apps.categories.models import Category

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'image']

class AdSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    category_detail = CategorySerializer(source='category', read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(), source='category', write_only=True
    )

    class Meta:
        model = Ad
        fields = [
            'id', 'user', 'category_detail', 'category_id', 'title', 
            'description', 'price', 'city', 'region', 'image', 
            'views', 'is_top', 'status', 'created_at', 'updated_at', 'expires_at'
        ]
        read_only_fields = ['id', 'user', 'views', 'is_top', 'created_at', 'updated_at', 'expires_at']
