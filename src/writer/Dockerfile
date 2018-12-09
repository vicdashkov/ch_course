FROM python:3.6
WORKDIR .
ADD requirements.txt .

RUN pip install -r requirements.txt
CMD ["python", "main.py"]

ENV PYTHONUNBUFFERED 1
ADD dashboard /app