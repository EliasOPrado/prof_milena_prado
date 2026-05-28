import json
from django.contrib import messages
from django.http import JsonResponse
from django.shortcuts import render, redirect, get_object_or_404
from django.urls import reverse
from django.views import View

from .forms import VideoForm
from .models import Video


class HomePageView(View):
    template_name = 'index.html'

    def get(self, request):
        form = VideoForm()
        return render(request, self.template_name, self.get_context(request, form))

    def post(self, request):
        form = VideoForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Vídeo publicado com sucesso no Canal Pedagógico!')
            return redirect(f"{reverse('home')}?tab=admin")

        return render(request, self.template_name, self.get_context(request, form))

    def get_context(self, request, form):
        server_videos = [
            {
                'id': f'server-video-{submission.pk}',
                'pk': submission.pk,
                'title': submission.title,
                'category': submission.category,
                'description': submission.description,
                'youtubeId': submission.youtube_id,
                'coverImage': submission.cover_image or f'https://img.youtube.com/vi/{submission.youtube_id}/0.jpg',
                'duration': submission.duration,
                'skills': [skill.strip() for skill in submission.skills.split(',') if skill.strip()],
                'activityTitle': submission.activity_title,
                'activityText': submission.activity_desc,
                'materialsNeeded': [item.strip() for item in submission.activity_materials.split(',') if item.strip()],
            }
            for submission in Video.objects.order_by('-created_at')
        ]

        latest_submission = Video.objects.order_by('-created_at').first()
        recent_submission = None
        if latest_submission:
            recent_submission = {
                'title': latest_submission.title,
                'category': latest_submission.category,
                'description': latest_submission.description,
                'youtube_url': latest_submission.youtube_url,
                'duration': latest_submission.duration,
                'skills': [skill.strip() for skill in latest_submission.skills.split(',') if skill.strip()],
                'cover_image': latest_submission.cover_image,
                'activity_title': latest_submission.activity_title,
                'activity_desc': latest_submission.activity_desc,
                'activity_materials': [item.strip() for item in latest_submission.activity_materials.split(',') if item.strip()],
            }

        return {
            'form': form,
            'form_data': request.POST.dict() if request.method == 'POST' else form.initial,
            'form_action_url': reverse('home'),
            'home_url': reverse('home'),
            'server_videos_json': json.dumps(server_videos, ensure_ascii=False),
            'recent_submission': recent_submission,
            'initial_tab': request.GET.get('tab', 'admin' if request.method == 'POST' else 'home'),
        }


class VideoEditView(View):
    def get(self, request, pk):
        video = get_object_or_404(Video, pk=pk)
        form = VideoForm(instance=video)
        # Reuse home context but force admin tab
        ctx = HomePageView().get_context(request, form)
        ctx['initial_tab'] = 'admin'
        ctx['form_action_url'] = reverse('video_edit', args=[pk])
        ctx['is_editing'] = True
        return render(request, 'index.html', ctx)

    def post(self, request, pk):
        video = get_object_or_404(Video, pk=pk)
        form = VideoForm(request.POST, instance=video)
        if form.is_valid():
            form.save()
            messages.success(request, 'Vídeo atualizado com sucesso!')
            return redirect(f"{reverse('home')}?tab=admin")

        ctx = HomePageView().get_context(request, form)
        ctx['initial_tab'] = 'admin'
        ctx['form_action_url'] = reverse('video_edit', args=[pk])
        ctx['is_editing'] = True
        return render(request, 'index.html', ctx)


class VideoDeleteView(View):
    def post(self, request, pk):
        video = get_object_or_404(Video, pk=pk)
        video.delete()
        # If AJAX request, return JSON for JS to handle
        if request.headers.get('x-requested-with') == 'XMLHttpRequest':
            return JsonResponse({'ok': True})

        messages.success(request, 'Vídeo removido com sucesso!')
        return redirect(f"{reverse('home')}?tab=admin")
