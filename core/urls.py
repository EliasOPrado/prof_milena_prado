from django.urls import path
from .views import HomePageView, VideoEditView, VideoDeleteView, admin_login, admin_logout

urlpatterns = [
    path('', HomePageView.as_view(), name='home'),
    path('videos/<int:pk>/edit/', VideoEditView.as_view(), name='video_edit'),
    path('videos/<int:pk>/delete/', VideoDeleteView.as_view(), name='video_delete'),
    path('admin-login/', admin_login, name='admin_login'),
    path('admin-logout/', admin_logout, name='admin_logout'),
]
