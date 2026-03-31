from rest_framework import viewsets, permissions
from .models import Favorite
from .serializers import FavoriteSerializer
from config.permissions import IsOwner

class FavoriteViewSet(viewsets.ModelViewSet):
    serializer_class = FavoriteSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwner]
    http_method_names = ['get', 'post', 'delete']

    def get_queryset(self):
        # returns only favorites owned by requested user
        return Favorite.objects.filter(user=self.request.user).select_related('ad', 'ad__user', 'ad__category')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
