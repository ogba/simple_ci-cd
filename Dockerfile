FROM python:3.12-slim

WORKDIR /app
COPY index.html ./

EXPOSE 8099
CMD ["python", "-m", "http.server", "8099", "--bind", "0.0.0.0"]
