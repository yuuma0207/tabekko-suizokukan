# uv + Python が入った公式イメージ
FROM ghcr.io/astral-sh/uv:python3.13-bookworm

ENV PYTHONUNBUFFERED=1

WORKDIR /app

# ---- OSパッケージ（build-essential） ----
# packages.txt に build-essential だけ入っている前提
# COPY packages.txt .
# RUN apt-get update && \
#     xargs -r apt-get install -y < packages.txt && \
#     rm -rf /var/lib/apt/lists/*

# ---- Python 依存関係をインストール（uv）----
# 先に依存ファイルとパッケージ本体だけコピーしてキャッシュを効かせる
COPY pyproject.toml uv.lock ./
COPY tabekko ./tabekko

# ロックファイルに従ってインストール（--frozen で lock とズレてたらエラー）
RUN uv sync --frozen --no-dev

# uv が作った venv を PATH に通す（デフォルトでは .venv）
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# ---- 残りのソース類をコピー ----
COPY streamlit_app.py ./streamlit_app.py
COPY README.md LICENSE ./
COPY data ./data
COPY fig ./fig

# Streamlit ポート
EXPOSE 8501

# コンテナ起動時コマンド（uv 経由で実行）
CMD ["uv", "run", "streamlit", "run", "streamlit_app.py", \
     "--server.port=8501", \
     "--server.address=0.0.0.0"]
