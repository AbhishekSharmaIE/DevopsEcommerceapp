from app import app as application

if __name__ == "__main__":
    # This is used when running locally only. When deploying to Elastic Beanstalk,
    # the application object itself is used by the gunicorn server
    application.run(host='0.0.0.0', port=5000) 