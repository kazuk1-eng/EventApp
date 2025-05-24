"""
In-memory database for Tokyo Weekend Events API
"""
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from passlib.context import CryptContext
import jwt
from app.models import Event, Location, Coordinates, ExternalLinks, NearbyPlace, User, Favorite, Schedule

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

SECRET_KEY = "tokyo_weekend_events_secret_key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

events: List[Event] = [
    Event(
        id=1,
        name="東京アートフェスティバル",
        description="週末に開催される東京最大のアートフェスティバル。様々なアーティストによる展示やパフォーマンスをお楽しみください。",
        start_datetime=datetime.now() + timedelta(days=2, hours=10),
        end_datetime=datetime.now() + timedelta(days=2, hours=18),
        location=Location(
            name="上野公園",
            address="東京都台東区上野公園",
            coordinates=Coordinates(latitude=35.7151, longitude=139.7734),
            area="上野",
            station="上野駅"
        ),
        category="アート",
        external_links=ExternalLinks(
            website="https://example.com/tokyo-art-festival",
            instagram="https://instagram.com/tokyoartfest",
            twitter="https://twitter.com/tokyoartfest"
        ),
        price=1000,
        capacity=5000
    ),
    Event(
        id=2,
        name="渋谷ミュージックフェス",
        description="渋谷の中心部で開催される音楽フェスティバル。人気バンドやDJによるライブパフォーマンスを体験しよう。",
        start_datetime=datetime.now() + timedelta(days=3, hours=12),
        end_datetime=datetime.now() + timedelta(days=3, hours=22),
        location=Location(
            name="渋谷ストリームホール",
            address="東京都渋谷区渋谷3-21-3",
            coordinates=Coordinates(latitude=35.6580, longitude=139.7016),
            area="渋谷",
            station="渋谷駅"
        ),
        category="音楽",
        external_links=ExternalLinks(
            website="https://example.com/shibuya-music-fest",
            instagram="https://instagram.com/shibuyamusicfest",
            twitter="https://twitter.com/shibuyamusicfest"
        ),
        price=3500,
        capacity=2000
    ),
    Event(
        id=3,
        name="池袋フードフェスティバル",
        description="池袋エリアの飲食店が集結する食のイベント。様々な国の料理や地元の名物を楽しめます。",
        start_datetime=datetime.now() + timedelta(days=1, hours=11),
        end_datetime=datetime.now() + timedelta(days=1, hours=20),
        location=Location(
            name="池袋西口公園",
            address="東京都豊島区西池袋1-8-26",
            coordinates=Coordinates(latitude=35.7295, longitude=139.7109),
            area="池袋",
            station="池袋駅"
        ),
        category="フード",
        external_links=ExternalLinks(
            website="https://example.com/ikebukuro-food-fest",
            instagram="https://instagram.com/ikebukurofoodfest"
        ),
        price=500,
        capacity=3000
    ),
    Event(
        id=4,
        name="新宿アニメコンベンション",
        description="アニメファン必見のイベント。コスプレコンテスト、声優トークショー、グッズ販売などが行われます。",
        start_datetime=datetime.now() + timedelta(days=4, hours=10),
        end_datetime=datetime.now() + timedelta(days=5, hours=18),
        location=Location(
            name="新宿NSビル",
            address="東京都新宿区西新宿2-4-1",
            coordinates=Coordinates(latitude=35.6934, longitude=139.6935),
            area="新宿",
            station="新宿駅"
        ),
        category="アニメ",
        external_links=ExternalLinks(
            website="https://example.com/shinjuku-anime-con",
            twitter="https://twitter.com/shinjukuanimecon"
        ),
        price=2000,
        capacity=10000
    ),
    Event(
        id=5,
        name="北千住クラフトマーケット",
        description="手作りの工芸品や雑貨が集まるマーケット。地元作家によるワークショップも開催されます。",
        start_datetime=datetime.now() + timedelta(days=6, hours=10),
        end_datetime=datetime.now() + timedelta(days=6, hours=16),
        location=Location(
            name="北千住マルイ前広場",
            address="東京都足立区千住3-92",
            coordinates=Coordinates(latitude=35.7489, longitude=139.8007),
            area="北千住",
            station="北千住駅"
        ),
        category="マーケット",
        external_links=ExternalLinks(
            instagram="https://instagram.com/kitasenju_craftmarket"
        ),
        price=0,
        capacity=1000
    ),
    Event(
        id=6,
        name="六本木アートナイト",
        description="一夜限りのアートの祭典。美術館やギャラリーが深夜まで開館し、街中がアート作品で彩られます。",
        start_datetime=datetime.now() + timedelta(days=5, hours=16),
        end_datetime=datetime.now() + timedelta(days=6, hours=5),
        location=Location(
            name="六本木ヒルズ",
            address="東京都港区六本木6-10-1",
            coordinates=Coordinates(latitude=35.6604, longitude=139.7292),
            area="六本木",
            station="六本木駅"
        ),
        category="アート",
        external_links=ExternalLinks(
            website="https://example.com/roppongi-art-night",
            instagram="https://instagram.com/roppongiartnightofficial",
            twitter="https://twitter.com/roppongiartnigh"
        ),
        price=0,
        capacity=50000
    ),
    Event(
        id=7,
        name="お台場ビーチフェスティバル",
        description="都心の人工ビーチで開催される夏のフェスティバル。ビーチスポーツやBBQ、音楽ライブなどが楽しめます。",
        start_datetime=datetime.now() + timedelta(days=7, hours=10),
        end_datetime=datetime.now() + timedelta(days=7, hours=20),
        location=Location(
            name="お台場海浜公園",
            address="東京都港区台場1-4-1",
            coordinates=Coordinates(latitude=35.6300, longitude=139.7750),
            area="お台場",
            station="お台場海浜公園駅"
        ),
        category="フェスティバル",
        external_links=ExternalLinks(
            website="https://example.com/odaiba-beach-festival",
            instagram="https://instagram.com/odaibabeachfest"
        ),
        price=1500,
        capacity=8000
    ),
    Event(
        id=8,
        name="銀座ファッションウィーク",
        description="銀座の各ショップが参加するファッションイベント。最新トレンドのファッションショーやワークショップが開催されます。",
        start_datetime=datetime.now() + timedelta(days=8, hours=11),
        end_datetime=datetime.now() + timedelta(days=14, hours=20),
        location=Location(
            name="銀座三越",
            address="東京都中央区銀座4-6-16",
            coordinates=Coordinates(latitude=35.6713, longitude=139.7636),
            area="銀座",
            station="銀座駅"
        ),
        category="ファッション",
        external_links=ExternalLinks(
            website="https://example.com/ginza-fashion-week",
            instagram="https://instagram.com/ginzafashionweek",
            twitter="https://twitter.com/ginzafashionwk"
        ),
        price=0,
        capacity=None
    ),
    Event(
        id=9,
        name="東京駅グルメフェア",
        description="東京駅構内の飲食店が参加するグルメイベント。限定メニューや特別価格のセットが楽しめます。",
        start_datetime=datetime.now() + timedelta(days=2, hours=10),
        end_datetime=datetime.now() + timedelta(days=8, hours=22),
        location=Location(
            name="東京駅一番街",
            address="東京都千代田区丸の内1-9-1",
            coordinates=Coordinates(latitude=35.6812, longitude=139.7671),
            area="東京",
            station="東京駅"
        ),
        category="フード",
        external_links=ExternalLinks(
            website="https://example.com/tokyo-station-gourmet-fair"
        ),
        price=0,
        capacity=None
    ),
    Event(
        id=10,
        name="日比谷音楽祭",
        description="日比谷公園で開催される無料の音楽フェスティバル。様々なジャンルのミュージシャンによるライブが楽しめます。",
        start_datetime=datetime.now() + timedelta(days=9, hours=12),
        end_datetime=datetime.now() + timedelta(days=10, hours=20),
        location=Location(
            name="日比谷公園大音楽堂",
            address="東京都千代田区日比谷公園1-5",
            coordinates=Coordinates(latitude=35.6731, longitude=139.7588),
            area="日比谷",
            station="日比谷駅"
        ),
        category="音楽",
        external_links=ExternalLinks(
            website="https://example.com/hibiya-music-festival",
            twitter="https://twitter.com/hibiyamusicfest"
        ),
        price=0,
        capacity=3000
    ),
    Event(
        id=11,
        name="丸の内イルミネーション",
        description="丸の内エリア一帯で開催される冬の風物詩。約200本の街路樹が約100万球のLEDで彩られます。",
        start_datetime=datetime.now() + timedelta(days=10, hours=17),
        end_datetime=datetime.now() + timedelta(days=90, hours=23),
        location=Location(
            name="丸の内仲通り",
            address="東京都千代田区丸の内1丁目",
            coordinates=Coordinates(latitude=35.6809, longitude=139.7650),
            area="丸の内",
            station="東京駅"
        ),
        category="イルミネーション",
        external_links=ExternalLinks(
            website="https://example.com/marunouchi-illumination",
            instagram="https://instagram.com/marunouchiillumination"
        ),
        price=0,
        capacity=None
    ),
    Event(
        id=12,
        name="浅草三社祭",
        description="浅草神社の例大祭。神輿の担ぎ手や纏持ちなど約500人の町会員が参加する勇壮な祭りです。",
        start_datetime=datetime.now() + timedelta(days=15, hours=9),
        end_datetime=datetime.now() + timedelta(days=17, hours=18),
        location=Location(
            name="浅草神社",
            address="東京都台東区浅草2-3-1",
            coordinates=Coordinates(latitude=35.7147, longitude=139.7966),
            area="浅草",
            station="浅草駅"
        ),
        category="祭り",
        external_links=ExternalLinks(
            website="https://example.com/asakusa-sanja-matsuri",
            instagram="https://instagram.com/asakusasanjamatsuri",
            twitter="https://twitter.com/asakusasanja"
        ),
        price=0,
        capacity=None
    )
]

nearby_places: List[NearbyPlace] = [
    NearbyPlace(
        id=1,
        name="上野寿司",
        type="restaurant",
        location=Location(
            name="上野寿司",
            address="東京都台東区上野7-1-1",
            coordinates=Coordinates(latitude=35.7141, longitude=139.7744),
            area="上野",
            station="上野駅"
        ),
        rating=4.5,
        price_level=3,
        description="伝統的な江戸前寿司を提供する老舗店"
    ),
    NearbyPlace(
        id=2,
        name="渋谷カフェ",
        type="cafe",
        location=Location(
            name="渋谷カフェ",
            address="東京都渋谷区宇田川町15-1",
            coordinates=Coordinates(latitude=35.6590, longitude=139.7010),
            area="渋谷",
            station="渋谷駅"
        ),
        rating=4.2,
        price_level=2,
        description="おしゃれな空間でくつろげるカフェ"
    ),
    NearbyPlace(
        id=3,
        name="池袋ホテル",
        type="hotel",
        location=Location(
            name="池袋ホテル",
            address="東京都豊島区東池袋1-5-6",
            coordinates=Coordinates(latitude=35.7300, longitude=139.7120),
            area="池袋",
            station="池袋駅"
        ),
        rating=4.0,
        price_level=3,
        description="駅から徒歩5分の便利なビジネスホテル"
    ),
    NearbyPlace(
        id=4,
        name="新宿居酒屋",
        type="restaurant",
        location=Location(
            name="新宿居酒屋",
            address="東京都新宿区歌舞伎町1-2-3",
            coordinates=Coordinates(latitude=35.6938, longitude=139.7030),
            area="新宿",
            station="新宿駅"
        ),
        rating=4.3,
        price_level=2,
        description="新鮮な魚介類と日本酒が自慢の居酒屋"
    ),
    NearbyPlace(
        id=5,
        name="北千住ネットカフェ",
        type="entertainment",
        location=Location(
            name="北千住ネットカフェ",
            address="東京都足立区千住2-20",
            coordinates=Coordinates(latitude=35.7485, longitude=139.8015),
            area="北千住",
            station="北千住駅"
        ),
        rating=3.8,
        price_level=1,
        description="24時間営業の快適なネットカフェ"
    ),
    NearbyPlace(
        id=6,
        name="六本木バー",
        type="restaurant",
        location=Location(
            name="六本木バー",
            address="東京都港区六本木7-4-5",
            coordinates=Coordinates(latitude=35.6622, longitude=139.7310),
            area="六本木",
            station="六本木駅"
        ),
        rating=4.6,
        price_level=4,
        description="夜景が美しい高層階のカクテルバー"
    ),
    NearbyPlace(
        id=7,
        name="お台場レストラン",
        type="restaurant",
        location=Location(
            name="お台場レストラン",
            address="東京都港区台場1-7-1",
            coordinates=Coordinates(latitude=35.6290, longitude=139.7730),
            area="お台場",
            station="台場駅"
        ),
        rating=4.1,
        price_level=3,
        description="海を眺めながら食事ができるレストラン"
    ),
    NearbyPlace(
        id=8,
        name="銀座高級ホテル",
        type="hotel",
        location=Location(
            name="銀座高級ホテル",
            address="東京都中央区銀座5-10-1",
            coordinates=Coordinates(latitude=35.6720, longitude=139.7650),
            area="銀座",
            station="銀座駅"
        ),
        rating=4.8,
        price_level=5,
        description="銀座の中心に位置する5つ星ホテル"
    ),
    NearbyPlace(
        id=9,
        name="東京駅カフェ",
        type="cafe",
        location=Location(
            name="東京駅カフェ",
            address="東京都千代田区丸の内1-9-1",
            coordinates=Coordinates(latitude=35.6812, longitude=139.7671),
            area="東京",
            station="東京駅"
        ),
        rating=4.0,
        price_level=2,
        description="駅構内にある便利なカフェ"
    ),
    NearbyPlace(
        id=10,
        name="日比谷バー",
        type="restaurant",
        location=Location(
            name="日比谷バー",
            address="東京都千代田区有楽町1-1-2",
            coordinates=Coordinates(latitude=35.6731, longitude=139.7588),
            area="日比谷",
            station="日比谷駅"
        ),
        rating=4.4,
        price_level=3,
        description="クラシックな雰囲気のカクテルバー"
    ),
    NearbyPlace(
        id=11,
        name="丸の内カフェ",
        type="cafe",
        location=Location(
            name="丸の内カフェ",
            address="東京都千代田区丸の内2-4-1",
            coordinates=Coordinates(latitude=35.6809, longitude=139.7650),
            area="丸の内",
            station="東京駅"
        ),
        rating=4.2,
        price_level=2,
        description="ビジネスマンに人気のモダンなカフェ"
    ),
    NearbyPlace(
        id=12,
        name="浅草旅館",
        type="hotel",
        location=Location(
            name="浅草旅館",
            address="東京都台東区浅草1-5-3",
            coordinates=Coordinates(latitude=35.7147, longitude=139.7966),
            area="浅草",
            station="浅草駅"
        ),
        rating=4.3,
        price_level=2,
        description="伝統的な和風旅館"
    )
]

users: List[User] = [
    User(
        id=1,
        username="testuser",
        email="test@example.com",
        is_active=True
    )
]

password_hashes = {
    "test@example.com": pwd_context.hash("password123")
}

favorites: List[Favorite] = [
    Favorite(id=1, user_id=1, event_id=1),
    Favorite(id=2, user_id=1, event_id=3)
]

schedules: List[Schedule] = []

def get_all_events():
    return events

def get_event_by_id(event_id: int):
    for event in events:
        if event.id == event_id:
            return event
    return None

def filter_events(area: str = None, station: str = None, 
                 start_date: datetime = None, end_date: datetime = None,
                 category: str = None):
    filtered = events
    
    if area:
        filtered = [e for e in filtered if e.location.area == area]
    
    if station:
        filtered = [e for e in filtered if e.location.station == station]
    
    if start_date:
        filtered = [e for e in filtered if e.start_datetime >= start_date]
    
    if end_date:
        filtered = [e for e in filtered if e.end_datetime <= end_date]
    
    if category:
        filtered = [e for e in filtered if e.category == category]
    
    return filtered

def search_events(query: str):
    if not query:
        return events
    
    query = query.lower()
    return [e for e in events if 
            query in e.name.lower() or 
            query in e.description.lower() or 
            query in e.category.lower() or 
            query in e.location.area.lower() or 
            (e.location.station and query in e.location.station.lower())]

def get_nearby_places(area: str = None, place_type: str = None):
    filtered = nearby_places
    
    if area:
        filtered = [p for p in filtered if p.location.area == area]
    
    if place_type:
        filtered = [p for p in filtered if p.type == place_type]
    
    return filtered

def get_user_by_email(email: str) -> Optional[User]:
    for user in users:
        if user.email == email:
            return user
    return None

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def authenticate_user(email: str, password: str) -> Optional[User]:
    user = get_user_by_email(email)
    if not user:
        return None
    if not verify_password(password, password_hashes.get(email, "")):
        return None
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def create_user(email: str, username: str, password: str) -> User:
    if get_user_by_email(email):
        return None
    
    user_id = max([u.id for u in users], default=0) + 1
    new_user = User(id=user_id, email=email, username=username, is_active=True)
    users.append(new_user)
    
    password_hashes[email] = get_password_hash(password)
    
    return new_user

def get_user_favorites(user_id: int) -> List[Event]:
    user_favorite_ids = [f.event_id for f in favorites if f.user_id == user_id]
    return [e for e in events if e.id in user_favorite_ids]

def add_favorite(user_id: int, event_id: int) -> Favorite:
    for fav in favorites:
        if fav.user_id == user_id and fav.event_id == event_id:
            return fav
    
    favorite_id = max([f.id for f in favorites], default=0) + 1
    new_favorite = Favorite(id=favorite_id, user_id=user_id, event_id=event_id)
    favorites.append(new_favorite)
    return new_favorite

def remove_favorite(user_id: int, event_id: int) -> bool:
    for i, fav in enumerate(favorites):
        if fav.user_id == user_id and fav.event_id == event_id:
            favorites.pop(i)
            return True
    return False

def get_user_schedule(user_id: int) -> List[Event]:
    user_schedule_ids = [s.event_id for s in schedules if s.user_id == user_id]
    return [e for e in events if e.id in user_schedule_ids]

def add_to_schedule(user_id: int, event_id: int, reminder: bool = False) -> Schedule:
    for sched in schedules:
        if sched.user_id == user_id and sched.event_id == event_id:
            return sched
    
    schedule_id = max([s.id for s in schedules], default=0) + 1
    new_schedule = Schedule(id=schedule_id, user_id=user_id, event_id=event_id, reminder=reminder)
    schedules.append(new_schedule)
    return new_schedule

def remove_from_schedule(user_id: int, event_id: int) -> bool:
    for i, sched in enumerate(schedules):
        if sched.user_id == user_id and sched.event_id == event_id:
            schedules.pop(i)
            return True
    return False
