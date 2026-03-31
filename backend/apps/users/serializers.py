from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth import get_user_model

User = get_user_model()

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['phone'] = user.phone
        return token
    
    def validate(self, attrs):
        # Override to use phone instead of username
        from django.contrib.auth import authenticate
        
        phone = attrs.get('phone') or attrs.get('username')
        password = attrs.get('password')
        
        if phone and password:
            user = authenticate(request=self.context.get('request'), phone=phone, password=password)
            if not user:
                raise serializers.ValidationError('No active account found with the given credentials')
        else:
            raise serializers.ValidationError('Must include "phone" and "password".')
            
        attrs['user'] = user
        return super().validate(attrs)

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'phone', 'username', 'password', 'created_at']
        extra_kwargs = {'password': {'write_only': True}}
        
    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user
