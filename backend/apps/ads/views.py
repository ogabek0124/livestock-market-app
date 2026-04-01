from rest_framework import viewsets, permissions
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
from .models import Ad
from .serializers import AdSerializer
from .filters import AdFilter
from config.permissions import IsOwnerOrReadOnly

from drf_spectacular.utils import extend_schema

@extend_schema(tags=['Ads'])
class AdViewSet(viewsets.ModelViewSet):
    queryset = Ad.objects.select_related('user', 'category').all()
    serializer_class = AdSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_class = AdFilter
    search_fields = ['title', 'description']
    ordering_fields = ['created_at', 'price', 'views']
    ordering = ['-created_at']

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def retrieve(self, request, *args, **kwargs):
        # Increment view count
        instance = self.get_object()
        instance.views += 1
        instance.save(update_fields=['views'])
        return super().retrieve(request, *args, **kwargs)
