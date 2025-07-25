# main.py
'''
터미널에서 아래 두줄을 터미널에 설치 해야함 순차적으로
pip install fastapi
pip install uvicorn[standard]

터미널에서 현재 파일의 위치로 이동(cd)이후 아래 터미널 명령어로 서버 켬
uvicorn main:app --reload
'''

# pip install fastap 로 fastapi 라이브러리 설치 후 진행


from fastapi import FastAPI, Request
import random
import requests
from dotenv import load_dotenv
import os
from openai import OpenAI


# .env 파일에 내용들을 불러옴
load_dotenv()
app = FastAPI()

# http://127.0.0.1:8000/docs#/ -> 라우팅 목록 페이지로 이동 가능.

# http://127.0.0.1:8000 는 http://localhost:8000/ 와 같은 의미!

# ngrok: https://e982cdfefae6.ngrok-free.app


@app.get('/')
def home():
    return{'home': 'sweet home'}

# ******  -----------------------------------------------------------  *******

def send_message(chat_id, massage):
    # .env 에서 'TELEGRAM_BOT_TOKEN' 에 해당하는 값을 불러옴
    bot_token = os.getenv('TELEGRAM_BOT_TOKEN')
    URL = f'http://api.telegram.org/bot{bot_token}'
    body = {
    # 사용자 chat_id 는 어디서 가져옴?         
    'chat_id': chat_id,
    'text': massage
    }
    requests.get(URL + '/sendMessage', body)


# /telegram 라우팅으로 텔레그램 서버가 Bot에 업데이트가 있을 경우, 우리에게 알려줌
@app.post('/telegram')
async def telegram(request: Request):
    print('텔레그램에서 요청이 들어왔다!!!!')

    data = await request.json()
    sender_id = data['message']['chat']['id']
    input_msg = data['message']['text']
    client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
    res = client.responses.create(
        model='gpt-4.1-mini',
        input=input_msg
        instructions='너는 아나운서와 같이 지식이 해박하고 목소리 또한 상냥해! '
    )

    send_message(sender_id, res.output_text)

    return{'status': '굿'}



@app.get('/lotto')
def lotto():
    return {
        'numbers' : random.sample(range(1, 46), 6) 
    }




