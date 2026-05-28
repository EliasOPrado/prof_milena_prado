from django.urls import path
from .views import HomePageView, VideoEditView, VideoDeleteView

urlpatterns = [
    path('', HomePageView.as_view(), name='home'),
    path('videos/<int:pk>/edit/', VideoEditView.as_view(), name='video_edit'),
    path('videos/<int:pk>/delete/', VideoDeleteView.as_view(), name='video_delete'),
]
