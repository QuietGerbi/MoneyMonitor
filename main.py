from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
import redis
import requests
import json
from sqlalchemy import create_engine, Column, String, Float, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import datetime

app = FastAPI()

# подключение redis и postgres
r = redis.Redis(host='redis', port=6379, db=0, decode_responses=True)

DATABASE_URL = "postgresql://user:password@db:5432/dbname"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# таблица в бд
class CurrencyRate(Base):
    __tablename__ = "rates"
    id = Column(String, primary_key=True, index=True)
    rate = Column(Float)
    updated_at = Column(DateTime, default=lambda: datetime.datetime.now(datetime.timezone.utc))

Base.metadata.create_all(bind=engine)

templates = Jinja2Templates(directory="templates")

def get_rates_from_api():
    response = requests.get("https://www.cbr-xml-daily.ru/daily_json.js")
    data = response.json()
    return {
        "USD": data["Valute"]["USD"]["Value"],
        "EUR": data["Valute"]["EUR"]["Value"],
        "CNY": data["Valute"]["CNY"]["Value"]
    }

@app.get("/", response_class=HTMLResponse)
def show_rates(request: Request):
    data = get_currency_rates() 
    
    return templates.TemplateResponse(
        request=request, 
        name="index.html", 
        context={
            "rates": data["rates"], 
            "source": data["source"]
        }
    )

@app.get("/rates")
def get_currency_rates():
    cached_rates = r.get("currency_rates")
    if cached_rates:
        return {"source": "cache", "rates": json.loads(cached_rates)}

    rates = get_rates_from_api()
    r.setex("currency_rates", 600, json.dumps(rates))

    db = SessionLocal()
    for code, value in rates.items():
        db_rate = db.query(CurrencyRate).filter(CurrencyRate.id == code).first()
        if db_rate:
            db_rate.rate = value
            db_rate.updated_at = datetime.now(datetime.timezone.utc)()
        else:
            db_rate = CurrencyRate(id=code, rate=value)
            db.add(db_rate)
    db.commit()
    db.close()

    return {"source": "api_and_db_updated", "rates": rates}

