# 실행 예시 (실행 스크립트로 정리)
from .graph import graph

config = {
    'configurable': {'thread_id': '1'}
}

question = '키를 기반으로 몸무게를 예측해야해. 키는 173이야.'
dataset = {
    "heights": [150,152,154,156,158,160,161,162,163,164,
                165,166,167,168,169,170,171,172,173,174,
                175,176,177,178,179,180,181,182,183,185],
    "weights": [45,48,49,50,52,54,55,56,57,58,
                59,60,61,62,63,64,65,66,67,68,
                70,71,72,73,74,75,77,78,79,82]
}

for step in graph.stream({
    'question': question,
    'dataset': dataset
}, config):
    print(step)