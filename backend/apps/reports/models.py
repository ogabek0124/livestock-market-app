from django.db import models
from django.conf import settings
from apps.ads.models import Ad

class Report(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='reports')
    ad = models.ForeignKey(Ad, on_delete=models.CASCADE, related_name='reports')
    reason = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Report by {self.user} on {self.ad}"
