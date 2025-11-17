from django.contrib.auth import get_user_model
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Item
from .serializers import ItemSerializer, UserRegistrationSerializer, UserSerializer


class UserViewSet(viewsets.ModelViewSet):
    queryset = get_user_model().objects.all()
    permission_classes = [permissions.AllowAny]  # Let anyone do anything for now

    def get_serializer_class(self):
        if self.action == "create":
            return UserRegistrationSerializer
        return UserSerializer

    # Remove the list() override completely for now
    # Let DRF handle everything

    @action(
        detail=False, methods=["get"], permission_classes=[permissions.IsAuthenticated]
    )
    def me(self, request):
        """Get current user's profile - this one still requires auth"""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

    @action(
        detail=False,
        methods=["put", "patch"],
        permission_classes=[permissions.IsAuthenticated],
    )
    def update_me(self, request):
        """Update current user's profile - requires auth"""
        serializer = self.get_serializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def test_auth(request):
    """Test endpoint to verify JWT authentication works"""
    return Response(
        {
            "message": f"Hello {request.user.username}! JWT authentication is working!",
            "user_id": request.user.id,
            "email": request.user.email,
        }
    )


# ItemViewSet remains the same
class ItemViewSet(viewsets.ModelViewSet):
    queryset = Item.objects.all().order_by("-created_at")
    serializer_class = ItemSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
