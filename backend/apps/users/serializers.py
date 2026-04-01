from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth import get_user_model

User = get_user_model()

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    phone = serializers.CharField(required=True)
    password = serializers.CharField(required=True, write_only=True)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Remove username field from JSON schema in Swagger
        self.fields.pop('username', None)

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['phone'] = user.phone
        return token
    
    def validate(self, attrs):
        from django.contrib.auth import authenticate
        
        phone = attrs.get('phone')
        password = attrs.get('password')
        
        if phone and password:
            user = authenticate(request=self.context.get('request'), phone=phone, password=password)
            if not user:
                raise serializers.ValidationError('Hisob topilmadi yoki parol xato.')
        else:
            raise serializers.ValidationError('Telefon raqam va parolni kiritish majburiy.')
            
        # Generating token response
        refresh = self.get_token(user)
        data = {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        }
        return data

class RegisterSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=20, required=True)
    full_name = serializers.CharField(max_length=50, required=False, allow_blank=True)

    def validate_phone_number(self, value):
        if User.objects.filter(phone=value).exists():
            raise serializers.ValidationError("Bu raqam allaqachon ro'yxatdan o'tgan.")
        return value

class SetPasswordSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=20, required=True)
    new_password = serializers.CharField(max_length=128, required=True, write_only=True)

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'phone', 'username', 'created_at']
