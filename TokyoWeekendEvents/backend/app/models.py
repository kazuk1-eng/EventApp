from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, HttpUrl, EmailStr


class Coordinates(BaseModel):
    latitude: float
    longitude: float


class Location(BaseModel):
    name: str
    address: str
    coordinates: Coordinates
    area: str
    station: Optional[str] = None


class ExternalLinks(BaseModel):
    website: Optional[HttpUrl] = None
    instagram: Optional[HttpUrl] = None
    twitter: Optional[HttpUrl] = None


class Event(BaseModel):
    id: int
    name: str
    description: str
    start_datetime: datetime
    end_datetime: datetime
    location: Location
    category: str
    external_links: ExternalLinks
    price: Optional[float] = None
    capacity: Optional[int] = None


class RouteOption(BaseModel):
    transport_type: str  # "walking", "driving", "transit", "bicycle", "taxi"
    duration_minutes: int
    distance_km: float
    steps: List[str]
    estimated_cost: Optional[float] = None


class NearbyPlace(BaseModel):
    id: int
    name: str
    type: str  # "restaurant", "cafe", "hotel", "entertainment"
    location: Location
    rating: Optional[float] = None
    price_level: Optional[int] = None
    description: Optional[str] = None


class UserBase(BaseModel):
    email: EmailStr
    username: str


class UserCreate(UserBase):
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class User(UserBase):
    id: int
    is_active: bool = True

    class Config:
        orm_mode = True


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    email: Optional[str] = None


class FavoriteBase(BaseModel):
    event_id: int


class FavoriteCreate(FavoriteBase):
    pass


class Favorite(FavoriteBase):
    id: int
    user_id: int

    class Config:
        orm_mode = True


class ScheduleBase(BaseModel):
    event_id: int
    reminder: bool = False


class ScheduleCreate(ScheduleBase):
    pass


class Schedule(ScheduleBase):
    id: int
    user_id: int

    class Config:
        orm_mode = True
