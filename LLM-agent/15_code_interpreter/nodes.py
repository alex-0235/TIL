from langchain_openai import ChatOpenAI
from typing_extensions import TypedDict, Annotated
from langchain_experimental.utilities import PythonREPL
import os, uuid

from state import State  # 같은 폴더 내 state.py 불러오기

llm = ChatOpenAI(model='gpt-4o', temperature=0)

class CodeBlock(TypedDict):
    code: Annotated[str, ..., '바로 실행 가능한 파이썬 코드']


def generate_code(state: State):
    prompt = f'''
    사용자 질문과 데이터셋을 제공할거야. 사용자 질문에 답변하기 위한 파이썬 코드를 생성해 줘.
    코드는 간단할수록 좋고, numpy, pandas, scikit-learn, scipy 가 설치되어 있으니 편하게 사용해.
    [주의] 이 코드는 실행될거기 때문에, 위험한 코드는 작성하면 안돼!
    ---
    질문: {state['question']}
    ---
    데이터셋: {state['dataset']}
    ---
    코드: 
    '''
    s_llm = llm.with_structured_output(CodeBlock)
    res = s_llm.invoke(prompt)
    return {'code': res['code']}


def execute_code(state: State):
    repl = PythonREPL()
    result = repl.run(state['code'])
    return {'result': result.strip()}


def generate_answer(state: State):
    prompt = f'''
    우리는 사용자 질문 -> 코드 -> 결과를 가지고 있어
    사용자의 질문과, 실행코드와 결과를 종합해 최종 답변을 생성해라.
    실행코드를 기반으로 왜 이 결과가 나왔는지 설명하면 된다.
    ---
    질문: {state['question']}
    ---
    코드: {state['code']}
    ---
    결과: {state['result']}
    ---
    최종 답변:
    '''
    res = llm.invoke(prompt)
    return {'answer': res}


def save_code(state: State):
    """
    코드를 특정 폴더에 저장합니다.
    """
    if not os.path.exists("codes"):
        os.makedirs("codes")

    filename = f"codes/code_{uuid.uuid4()}.py"
    question = state.get('question', 'No question provided.')
    code_to_save = state.get('code', '')

    docstring = f'"""\n[USER QUESTION]\n{question}\n"""\n\n'
    content_to_save = docstring + code_to_save

    with open(filename, "w", encoding="utf-8") as f:
        f.write(content_to_save)

    return {}