# main.py
'''
터미널에서 아래 두줄을 터미널에 설치 해야함 순차적으로
pip install fastapi
pip install uvicorn[standard]

이후 아래 터미널 명령어로 서버 켬
uvicorn main:app --reload
'''

# pip install fastap 로 fastapi 라이브러리 설치 후 진행


from fastapi import FastAPI
import random

app = FastAPI()



@app.get('/hi')
def hi():
    return {'status': '굿'}

@app.get('/lotto')
def lotto():
    return {
        'numbers' : random.sample(range(1, 46), 6) 
    }


@app.get('/gogogo')
def gogogo():

    return {'status' : 'gogogo'}
