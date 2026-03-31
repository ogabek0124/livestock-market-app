from rest_framework import serializers
from .models import Favorite
from apps.ads.serializers import AdSerializer
from apps.ads.models import Ad

class FavoriteSerializer(serializers.ModelSerializer):
    ad_detail = AdSerializer(source='ad', read_only=True)
    ad_id = serializers.PrimaryKeyRelatedField(
        queryset=Ad.objects.all(), source='ad', write_only=True
    )

    class Meta:
        model = Favorite
        fields = ['id', 'ad_detail', 'ad_id', 'created_at']
        read_only_fields = ['id', 'created_at']
