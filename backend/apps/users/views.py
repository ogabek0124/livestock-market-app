from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from rest_framework_simplejwt.views import TokenObtainPairView
from django.contrib.auth import get_user_model
from drf_spectacular.utils import extend_schema
from .serializers import (
    CustomTokenObtainPairSerializer, 
    UserSerializer, 
    RegisterSerializer, 
    SetPasswordSerializer
)

User = get_user_model()

@extend_schema(tags=['Authentication'])
class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

@extend_schema(tags=['Authentication'], request=RegisterSerializer)
class RegisterView(APIView):
    permission_classes = (permissions.AllowAny,)
    
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            phone = serializer.validated_data['phone_number']
            full_name = serializer.validated_data.get('full_name', '')
            
            # Create a user without a usable password
            user = User(phone=phone, username=full_name)
            user.set_unusable_password() 
            user.is_active = False # Will be active after password is set
            user.save()
            
            return Response({
                "success": True, 
                "message": "Muvaffaqiyatli ro'yxatdan o'tdingiz. Iltimos, parol o'rnating."
            }, status=status.HTTP_201_CREATED)
        return Response({"success": False, "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

@extend_schema(tags=['Authentication'], request=SetPasswordSerializer)
class SetPasswordView(APIView):
    permission_classes = (permissions.AllowAny,)

    def post(self, request):
        serializer = SetPasswordSerializer(data=request.data)
        if serializer.is_valid():
            phone = serializer.validated_data['phone_number']
            new_password = serializer.validated_data['new_password']
            
            try:
                user = User.objects.get(phone=phone)
                user.set_password(new_password)
                user.is_active = True
                user.save()
                return Response({
                    "success": True, 
                    "message": "Parol muvaffaqiyatli o'rnatildi. Endi tizimga kirishingiz mumkin."
                }, status=status.HTTP_200_OK)
            except User.DoesNotExist:
                return Response({
                    "success": False, 
                    "message": "Foydalanuvchi topilmadi."
                }, status=status.HTTP_404_NOT_FOUND)
                
        return Response({"success": False, "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

@extend_schema(tags=['Authentication'])
class CurrentUserView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)
