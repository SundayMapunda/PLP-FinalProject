from django.urls import include, path
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register(
    r"items", views.ItemViewSet
)  # We'll use ViewSets for efficiency later, but let's start with this.

urlpatterns = [
    path("api/", include(router.urls)),
    path("api/items/", views.ItemListCreateView.as_view(), name="item-list-create"),
    path("api/items/<int:pk>/", views.ItemDetailView.as_view(), name="item-detail"),
]
