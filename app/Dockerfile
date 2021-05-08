FROM python:3.8-alpine
WORKDIR /code
RUN apk add --no-cache bash curl
COPY src/requirements.txt .
RUN pip install -r requirements.txt
COPY src/ .
ENTRYPOINT [ "python" ]
CMD ["app.py"]
