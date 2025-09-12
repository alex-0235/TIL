from langgraph.graph import MessagesState
from typing_extensions import Any

class State(MessagesState):
    question: str  # 사용자 질문
    dataset: Any   # 임의의 데이터셋(추후엔 DB에서 가져오거나 해야함)
    code: str      # 파이썬 코드 블럭
    result: str    # `code`의 실행결과
    answer: str    # 최종 답변