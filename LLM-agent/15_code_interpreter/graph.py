from langgraph.graph import StateGraph, START, END
from state import State
from nodes import generate_code, execute_code, generate_answer, save_code

builder = StateGraph(State)

# 기존 순차 실행 (코드 생성 → 실행 → 답변)
builder.add_sequence([generate_code, execute_code, generate_answer])

# generate_code 이후에 save_code도 실행되도록
builder.add_edge("generate_code", "save_code")

# save_code 노드를 추가로 등록
builder.add_node("save_code", save_code)

# 추가: 코드 생성 후 save_code도 실행
builder.add_edge("generate_code", "save_code")

# 시작/끝 연결
builder.add_edge(START, "generate_code")
builder.add_edge("generate_answer", END)

graph = builder.compile()