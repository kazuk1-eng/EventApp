from datetime import datetime, timedelta
from typing import List, Optional
from fastapi import FastAPI, Query, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt

from app.models import Event, RouteOption, NearbyPlace, User, UserCreate, UserLogin, Token, Favorite, Schedule
from app.database_updated import (
    get_all_events, get_event_by_id, filter_events, get_nearby_places, search_events,
    authenticate_user, create_user, create_access_token, get_user_by_email,
    get_user_favorites, add_favorite, remove_favorite,
    get_user_schedule, add_to_schedule, remove_from_schedule,
    SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES
)

app = FastAPI(title="Tokyo Weekend Events API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="認証情報が無効です",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = get_user_by_email(email)
    if user is None:
        raise credentials_exception
    return user

@app.get("/")
async def root():
    return {"message": "Welcome to Tokyo Weekend Events API"}

@app.get("/events", response_model=List[Event])
async def read_events(
    area: Optional[str] = Query(None, description="Filter by area (e.g., 北千住, 池袋)"),
    station: Optional[str] = Query(None, description="Filter by station (e.g., 新宿駅, 東京駅)"),
    start_date: Optional[str] = Query(None, description="Filter by start date (YYYY-MM-DD)"),
    end_date: Optional[str] = Query(None, description="Filter by end date (YYYY-MM-DD)"),
    category: Optional[str] = Query(None, description="Filter by category")
):
    start_datetime = None
    end_datetime = None
    
    if start_date:
        try:
            start_datetime = datetime.strptime(start_date, "%Y-%m-%d")
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid start_date format. Use YYYY-MM-DD")
    
    if end_date:
        try:
            end_datetime = datetime.strptime(end_date, "%Y-%m-%d")
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid end_date format. Use YYYY-MM-DD")
    
    return filter_events(area, station, start_datetime, end_datetime, category)

@app.get("/events/search", response_model=List[Event])
async def search_events_endpoint(query: str = Query(..., description="Search query")):
    results = search_events(query)
    if not results:
        return []
    return results

@app.get("/events/{event_id}", response_model=Event)
async def read_event(event_id: int):
    event = get_event_by_id(event_id)
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    return event

@app.get("/events/{event_id}/routes", response_model=List[RouteOption])
async def get_routes(
    event_id: int,
    from_lat: float = Query(..., description="Starting point latitude"),
    from_lng: float = Query(..., description="Starting point longitude"),
    transport_types: Optional[str] = Query("walking,driving,transit", 
                                          description="Comma-separated list of transport types")
):
    event = get_event_by_id(event_id)
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    
    types = transport_types.split(",")
    routes = []
    
    if "walking" in types:
        routes.append(RouteOption(
            transport_type="walking",
            duration_minutes=30,
            distance_km=2.5,
            steps=["Start at your location", "Walk north on Main Street", "Turn right at Park Avenue", 
                  f"Arrive at {event.location.name}"],
            estimated_cost=0
        ))
    
    if "driving" in types:
        routes.append(RouteOption(
            transport_type="driving",
            duration_minutes=15,
            distance_km=5.0,
            steps=["Start driving from your location", "Head east on Highway 1", 
                  "Take exit 23 toward City Center", f"Arrive at {event.location.name}"],
            estimated_cost=500  # Parking fee
        ))
    
    if "transit" in types:
        routes.append(RouteOption(
            transport_type="transit",
            duration_minutes=25,
            distance_km=6.0,
            steps=["Walk to nearest station", "Take Yamanote Line to Shinjuku Station", 
                  "Transfer to Chuo Line", f"Exit at station near {event.location.name}", 
                  f"Walk 5 minutes to {event.location.name}"],
            estimated_cost=280  # Train fare
        ))
    
    if "bicycle" in types:
        routes.append(RouteOption(
            transport_type="bicycle",
            duration_minutes=20,
            distance_km=4.0,
            steps=["Start cycling from your location", "Take the bike path along the river", 
                  f"Turn left at the park", f"Arrive at {event.location.name}"],
            estimated_cost=0
        ))
    
    if "taxi" in types:
        routes.append(RouteOption(
            transport_type="taxi",
            duration_minutes=12,
            distance_km=5.0,
            steps=["Get a taxi from your location", f"Direct route to {event.location.name}"],
            estimated_cost=2000  # Taxi fare
        ))
    
    return routes

@app.get("/nearby/{area}", response_model=List[NearbyPlace])
async def get_nearby_places_by_area(
    area: str,
    place_type: Optional[str] = Query(None, description="Filter by place type (restaurant, cafe, hotel, entertainment)")
):
    places = get_nearby_places(area, place_type)
    if not places:
        raise HTTPException(status_code=404, detail=f"No places found in {area}")
    return places

@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="メールアドレスまたはパスワードが正しくありません",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/users/register", response_model=User)
async def register_user(user_data: UserCreate):
    existing_user = get_user_by_email(user_data.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="このメールアドレスは既に登録されています",
        )
    user = create_user(user_data.email, user_data.username, user_data.password)
    return user

@app.get("/users/me", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user

@app.get("/users/favorites", response_model=List[Event])
async def get_favorites(current_user: User = Depends(get_current_user)):
    return get_user_favorites(current_user.id)

@app.post("/events/{event_id}/favorite", response_model=Favorite)
async def favorite_event(event_id: int, current_user: User = Depends(get_current_user)):
    event = get_event_by_id(event_id)
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    
    favorite = add_favorite(current_user.id, event_id)
    return favorite

@app.delete("/events/{event_id}/favorite", status_code=204)
async def unfavorite_event(event_id: int, current_user: User = Depends(get_current_user)):
    event = get_event_by_id(event_id)
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    
    success = remove_favorite(current_user.id, event_id)
    if not success:
        raise HTTPException(status_code=404, detail="Favorite not found")
    return None

@app.get("/users/schedule", response_model=List[Event])
async def get_schedule(current_user: User = Depends(get_current_user)):
    return get_user_schedule(current_user.id)

@app.post("/events/{event_id}/schedule", response_model=Schedule)
async def schedule_event(
    event_id: int, 
    reminder: bool = Query(False, description="Set reminder for this event"),
    current_user: User = Depends(get_current_user)
):
    event = get_event_by_id(event_id)
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    
    schedule = add_to_schedule(current_user.id, event_id, reminder)
    return schedule

@app.delete("/events/{event_id}/schedule", status_code=204)
async def unschedule_event(event_id: int, current_user: User = Depends(get_current_user)):
    event = get_event_by_id(event_id)
    if event is None:
        raise HTTPException(status_code=404, detail="Event not found")
    
    success = remove_from_schedule(current_user.id, event_id)
    if not success:
        raise HTTPException(status_code=404, detail="Schedule not found")
    return None
