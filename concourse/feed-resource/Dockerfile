FROM python:3.9.6

COPY requirements-freeze.txt .
RUN pip install -r requirements-freeze.txt

COPY ./src/* /opt/resource/
