FROM pytorch/pytorch:lastest

RUN apt update -y && \
    apt upgrade -y && \
    apt autoremove -y && \
    pip install --upgrade pip && \
    python -m pip install milvus && \
    pip install openai
