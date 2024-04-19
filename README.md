# SOLWOE

SOLWOE, is a mental health app that helps diagnose and treat depression among teenageers. SOLWOE uses PHQ-9 questionnaire to assess teenagers and offer them self-care options like yoga, meditation, music videos and diary writing, as well as guided care like in-person or video consultation with a psychiatrist. Additionally the app had an SOS feature that connects users to Tamil Nadu's helpline and a mood tracker to track their mood.

## App Demo

https://user-images.githubusercontent.com/54678239/235072696-8b0854f4-fade-4c7d-8193-05889675a229.mp4

## How to use the app

1. Fork this repository
2. Clone the forked repository.
3. Create a firebase project, configure the project and add the google_services.json
4. Add your stripe publishable key in main.dart
5. Add your stripe secret key in payment_screen.dart
6. Add your agora api key in video_consultation_screen.dart
7. Create a token server and add the URL in the getToken function in the video_consultation_screen.dart

19/4/24 edit:
run the text emotion and face emotion detection model in a flask server and put the endpoint url in respective firebase collection. solwoe will fetch it from there
https://github.com/bharathkj/final-yr-project-models
