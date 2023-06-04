FROM bitnami/pytorch:latest

ENV REPO https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main
ENV HUBERT_MDL $REPO/hubert_base.pt
ENV PTV2 $REPO/pretrained_v2
ENV D40K_MDL $PTV2/D40k.pth
ENV G40K_MDL $PTV2/G40k.pth
ENV F0D40K_MDL $PTV2/f0D40k.pth
ENV F0G40K_MDL $PTV2/f0G40k.pth
ENV WEIGHTS $REPO/weights/%E7%99%BD%E8%8F%9C357k.pt
ENV UVR5 $REPO/uvr5_weights

USER root
RUN echo 'root:abc' | chpasswd

# Sources for nvtop:
RUN sed -i '/^deb.*bullseye main$/a deb http://deb.debian.org/debian bullseye contrib non-free' /etc/apt/sources.list && \
    sed -i '/^deb.*bullseye-updates main$/a deb http://deb.debian.org/debian bullseye-updates contrib non-free' /etc/apt/sources.list

# Upgrade and install packages:
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y build-essential curl ffmpeg git htop nvtop tmux && \
    apt autoremove -y

# Set up aliases:
RUN echo "alias cls='clear'" >> /root/.bashrc && \
    echo "alias l='ls -la --color'" >> /root/.bashrc && \
    echo "alias ..='cd ..'" >> /root/.bashrc && \
    echo "alias ...='cd ../..'" >> /root/.bashrc

# Install some base AI-related packages:
RUN pip install --upgrade pip && \
    python -m pip install milvus && \
    pip install openai

# Install RVC-ui:
RUN mkdir /projects && \
    cd /projects && \
    git clone https://github.com/ath/RVC-ui.git && \
    cd RVC-ui && \
    curl -LJO $HUBERT_MDL && \
    cd pretrained_v2 && \
    curl -LJO $D40K_MDL && \
    curl -LJO $G40K_MDL && \
    curl -LJO $F0D40K_MDL && \
    curl -LJO $F0G40K_MDL && \
    cd ../weights && \
    curl -LJO $WEIGHTS && \
    cd .. && \
    cd uvr5_weights && \
    curl -LJO $UVR5/HP2-%E4%BA%BA%E5%A3%B0vocals%2B%E9%9D%9E%E4%BA%BA%E5%A3%B0instrumentals.pth && \
    curl -LJO $UVR5/HP2_all_vocals.pth && \
    curl -LJO $UVR5/HP3_all_vocals.pth && \
    curl -LJO $UVR5/HP5-%E4%B8%BB%E6%97%8B%E5%BE%8B%E4%BA%BA%E5%A3%B0vocals%2B%E5%85%B6%E4%BB%96instrumentals.pth && \
    curl -LJO $UVR5/HP5_only_main_vocal.pth && \
    curl -LJO $UVR5/VR-DeEchoAggressive.pth && \
    curl -LJO $UVR5/VR-DeEchoDeReverb.pth && \
    curl -LJO $UVR5/VR-DeEchoNormal.pth && \
    mkdir onnx_dereverb_By_FoxJoy && \
    cd onnx_dereverb_By_FoxJoy && \
    curl -LJO $UVR5/onnx_dereverb_By_FoxJoy/vocals.onnx

# Install RVC deps:
RUN cd ../.. && \
    pip install -r requirements.txt

# Place onstart.sh in /root:
RUN cd /root && \
    echo "#!/bin/bash" >> onstart.sh && \
    echo "tmux new-session -s gpu_session -c /projects/RVC-ui" >> onstart.sh && \
    chmod +x onstart.sh

WORKDIR /projects/RVC-ui
#CMD ["tmux", "new-session", "-s", "gpu_session", "-c", "/projects/RVC-ui"]
