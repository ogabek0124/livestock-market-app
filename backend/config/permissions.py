from rest_framework import permissions

class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Object-level permission to only allow owners of an object to edit it.
    Assumes the model instance has an `owner` or `user` attribute.
    """
    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request,
        if request.method in permissions.SAFE_METHODS:
            return True

        # Instance must have an attribute named `user`.
        return getattr(obj, 'user', None) == request.user

class IsOwner(permissions.BasePermission):
    """
    Object-level permission to only allow owners of an object to access it.
    """
    def has_object_permission(self, request, view, obj):
        return getattr(obj, 'user', None) == request.user
