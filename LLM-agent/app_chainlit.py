# app_chainlit.py
import os
import chainlit as cl

# === 1) 기존 Agent+RAG 코드를 함수로 감싸 세션별 인스턴스 생성 ===
def build_agent_executor():
    from langchain.agents import create_openai_tools_agent, AgentExecutor
    from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
    from langchain.memory import ConversationBufferMemory
    from langchain_tavily import TavilySearch
    from datetime import datetime
    from langchain_community.document_loaders import PyMuPDFLoader
    from langchain.text_splitter import RecursiveCharacterTextSplitter
    from langchain_openai import ChatOpenAI, OpenAIEmbeddings
    from langchain_community.vectorstores import FAISS
    from langchain.tools.retriever import create_retriever_tool

    today = datetime.today().strftime('%Y-%m-%d')
    llm = ChatOpenAI(model='gpt-4.1-nano')

    search_tool = TavilySearch(max_results=5, topic='general')

    loader = PyMuPDFLoader('./spri.pdf')
    docs = loader.load()
    splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
    split_docs = splitter.split_documents(docs)
    embedding = OpenAIEmbeddings()
    vectorstore = FAISS.from_documents(split_docs, embedding=embedding)
    retriever = vectorstore.as_retriever()

    rag_tool = create_retriever_tool(
        retriever,
        name='pdf_search',
        description='PDF 문서에서 질문과 관련된 내용을 검색합니다.'
    )

    system_text = f"""
    너는 웹 검색이 가능하고, 2023년 12월 인공지능 산업 최신동향 정보를 담은 pdf 를 검색할 수 있는 어시스턴트야.
    - 사용자가 PDF 문서와 관련된 질문(ex. '이 pdf에서', '문서내용', '파일에서)을 하면 반드시 'pdf_search' 도구를 써야해
    - 사용자 질문이 팩트체크를 필요로 하고, 최신성이 필요하다 판단되면 web_search를 실행해야해
    - 사용자가 일반적인 질문을 하고, 최신성이나 팩트체크가 필요없으면 그냥 답변해
    - 뭔가 확실하지 않으면 pdf_search 와 web_search를 모두 실행해서 답변을 생성해
    오늘은 {today} 야.
    """

    prompt = ChatPromptTemplate.from_messages([
        ('system', system_text),
        MessagesPlaceholder(variable_name='chat_history'),
        ('human', '{input}'),
        MessagesPlaceholder(variable_name='agent_scratchpad')
    ])

    memory = ConversationBufferMemory(return_messages=True, memory_key='chat_history')

    agent = create_openai_tools_agent(llm=llm, tools=[search_tool, rag_tool], prompt=prompt)

    agent_executor = AgentExecutor(
        agent=agent,
        memory=memory,
        tools=[search_tool, rag_tool],
        verbose=True
    )
    return agent_executor

# === 2) Chainlit 훅: 세션 시작 시 에이전트 만들고, 메시지 올 때마다 invoke ===
@cl.on_chat_start
async def on_start():
    cl.user_session.set("agent", build_agent_executor())
    await cl.Message(content="안녕하세요! PDF와 웹을 함께 검색해 드릴게요. 무엇이든 물어보세요.").send()

@cl.on_message
async def on_message(message: cl.Message):
    agent = cl.user_session.get("agent")
    # invoke는 동기 함수라 make_async로 감싸 비동기 처리
    result = await cl.make_async(agent.invoke)({"input": message.content})
    await cl.Message(content=result).send()

# http://127.0.0.1:8000/?utm_source=chatgpt.com  에서 확인 가능