
from django.conf.urls import include, url
from django.contrib import admin
from django.conf import settings
from django.conf.urls.static import static

from prediction.cancer import views

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^uploads/form/$', views.model_form_upload, name='model_form_upload'),
    url(r'^$', views.home, name='home'),
]

if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
