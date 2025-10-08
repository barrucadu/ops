FROM python:3.14.0

COPY requirements-freeze.txt .
RUN pip install -r requirements-freeze.txt

COPY ./src/* /opt/resource/
