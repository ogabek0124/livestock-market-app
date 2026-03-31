from rest_framework import viewsets
from .models import Category
from .serializers import CategorySerializer

class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    pagination_class = None # typically categories don't need pagination unless too many
