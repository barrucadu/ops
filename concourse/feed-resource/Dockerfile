FROM python:3.11.1

COPY requirements-freeze.txt .
RUN pip install -r requirements-freeze.txt

COPY ./src/* /opt/resource/
