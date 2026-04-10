# resiflow_mobile

Application mobile Flutter de ResiFlow.

## Setup technique

Le projet utilise :

- `flutter_riverpod` pour l'injection et l'etat
- `dio` pour l'acces API
- `go_router` pour la navigation

## Configuration d'environnement

La configuration runtime utilise des `--dart-define`.

### Developpement

```bash
flutter run --dart-define=APP_ENV=dev
```

Par defaut, l'environnement `dev` cible :

- `http://127.0.0.1:8080` sur desktop/web
- `http://10.0.2.2:8080` sur emulateur Android

### Production

```bash
flutter run \
  --dart-define=APP_ENV=prod \
  --dart-define=API_BASE_URL=https://your-production-api
```

Aucune URL de production n'est fournie par defaut. Elle doit etre definie explicitement via `API_BASE_URL`.
