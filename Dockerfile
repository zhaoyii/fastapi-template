# 使用更小的基础镜像
FROM python:3.9-slim as requirements-stage

WORKDIR /tmp

# 安装 poetry
RUN pip install poetry

# 复制项目依赖文件
COPY ./pyproject.toml ./poetry.lock* /tmp/

# 导出 requirements.txt
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

# 使用更小的基础镜像来减少最终镜像大小
FROM python:3.9-slim

# 创建并设置工作目录
WORKDIR /code

# 从上一阶段复制 requirements.txt
COPY --from=requirements-stage /tmp/requirements.txt /code/requirements.txt

# 安装依赖，不使用缓存
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# 复制应用代码
COPY ./app /code/app

# 暴露应用运行端口
EXPOSE 80

# 设置启动命令
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
