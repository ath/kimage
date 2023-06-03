FROM bitnami/pytorch:latest

ENV REPO https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main
ENV HUBERT_MDL $REPO/hubert_base.pt
ENV PTV2 $REPO/pretrained_v2
ENV D40K_MDL $PTV2/D40k.pth
ENV G40K_MDL $PTV2/G40k.pth
ENV F0D40K_MDL $PTV2/f0D40k.pth
ENV F0G40K_MDL $PTV2/f0G40k.pth

USER root
RUN echo 'root:abc' | chpasswd

RUN apt update -y && \
    apt upgrade -y && \
    apt install -y build-essential curl git htop tmux && \
    apt autoremove -y && \
    echo "alias cls='clear'" >> /root/.bashrc && \
    echo "alias l='ls -la --color'" >> /root/.bashrc && \
    echo "alias ..='cd ..'" >> /root/.bashrc && \
    echo "alias ...='cd ../..'" >> /root/.bashrc && \
    pip install --upgrade pip && \
    python -m pip install milvus && \
    pip install openai && \
    mkdir /project && \
    cd /project && \
    git clone https://github.com/ath/RVC-ui.git && \
    cd RVC-ui && \
    curl -LJO $HUBERT_MDL && \
    cd pretrained_v2 && \
    curl -LJO $D40K_MDL && \
    curl -LJO $G40K_MDL && \
    curl -LJO $F0D40K_MDL && \
    curl -LJO $F0G40K_MDL && \
    cd .. && \
    pip install -r requirements.txt

WORKDIR /project/RVC-ui
CMD ["tmux", "new-session", "-s", "gpu_session", "-c", "/project/RVC-ui"]
