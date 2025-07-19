To run this application, use Docker source image with python3.9+
INstall requirements with `pip install -r requirements.txt`

1. Install necessary dependencies:

```
pip3 install -r requirements.txt
```

2. Run application with:

 - For development only:
```
FLASK_APP=main.py
flask run --host=0.0.0.0 --port=8080
```

 - In production:

```
uwsgi --http 0.0.0.0:8080 --master --workers 4 --wsgi wsgi:app --die-on-term
```