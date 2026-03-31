from django_filters import rest_framework as filters
from .models import Ad

class AdFilter(filters.FilterSet):
    min_price = filters.NumberFilter(field_name="price", lookup_expr='gte')
    max_price = filters.NumberFilter(field_name="price", lookup_expr='lte')

    class Meta:
        model = Ad
        fields = ['category', 'city']
