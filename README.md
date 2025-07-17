# Cheerz Spring Boot CI/CD Project

## Description

Ce projet démontre la mise en place d'un pipeline CI/CD pour une application Spring Boot avec déploiement sur Google Cloud Platform. L'application est une simple application qui retourne "Hello Docker World".

## Architecture

- **Application** : Spring Boot 3.3.0 avec Java 17
- **Build** : Gradle 8.5
- **Containerisation** : Docker multi-stage build
- **CI/CD** : GitHub Actions
- **Registry** : Google Artifact Registry
- **Déploiement** : Google Cloud Run

## Structure du projet

```
cheerz-spring/
├── .github/workflows/
│   └── ci-cd.yml              # Pipeline CI/CD
├── src/
│   ├── main/
│   │   ├── java/hello/
│   │   │   └── Application.java
│   │   └── resources/
│   │       └── application.yml
│   └── test/
├── build.gradle               # Configuration Gradle
├── settings.gradle           # Configuration du projet
├── Dockerfile               # Image Docker optimisée
└── README.md               # Cette documentation
```

## Pipeline CI/CD

Le pipeline GitHub Actions comprend 2 jobs principaux :

### 1. Test (`test`)
- Configuration de l'environnement Java 17
- Cache des dépendances Gradle
- Exécution des tests unitaires
- Build de l'application

### 2. Build and Deploy (`build-and-deploy`)
- Build de l'application avec Gradle
- Construction de l'image Docker multi-stage
- Push vers Google Artifact Registry
- Déploiement automatique sur Cloud Run

## Choix de la plateforme de déploiement : Google Cloud Run

**Justification du choix :**

J'ai choisi Google Cloud Run pour les raisons suivantes :
- **Serverless** : Pas de gestion d'infrastructure, scaling automatique
- **Pay-per-use** : Facturation uniquement pendant l'exécution des requêtes
- **Simplicité** : Déploiement direct depuis une image Docker
- **Performance** : Démarrage rapide et gestion automatique du trafic

## Instructions de déploiement sur GCP

### 1. Prérequis
- Compte Google Cloud Platform avec facturation activée
- Projet GCP créé
- APIs activées : Cloud Run, Artifact Registry, IAM

```bash
# Activation des services
gcloud config set project cheerz-spring
gcloud services enable run.googleapis.com \
                       artifactregistry.googleapis.com \
                       iam.googleapis.com
```
### 2. Configuration du service account
```bash
# Créer le service account
gcloud iam service-accounts create github-deployer \
  --display-name "GitHub Actions deployer"

# Attribuer les rôles
gcloud projects add-iam-policy-binding cheerz-spring \
  --member="serviceAccount:github-deployer@cheerz-spring.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding cheerz-spring \
  --member="serviceAccount:github-deployer@cheerz-spring.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding cheerz-spring] \
  --member="serviceAccount:github-deployer@cheerz-spring.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.admin"

# Générer la clé JSON
gcloud iam service-accounts keys create key.json \
  --iam-account=github-deployer@cheerz-spring.iam.gserviceaccount.com
```

### 3. Configuration des secrets GitHub

1. Allez dans **Settings > Secrets and variables > Actions** de votre dépôt GitHub.  
2. Ajoutez un secret nommé `GCP_PROJECT_ID` avec l’ID de votre projet Google Cloud.  
3. Ajoutez un secret nommé `GCP_REGION` avec la région de votre Cloud Run.  
4. Ajoutez un secret nommé `CLOUD_RUN_SERVICE_NAME` avec le nom de votre service Cloud Run.  
5. Ajoutez un secret nommé `GCP_SA_KEY` avec le contenu complet du fichier `key.json` (copiez-collez tout le contenu JSON).

### 4. Déploiement
Le déploiement se fait automatiquement à chaque push sur la branche `master`.

## Développement local

### Build et test
```bash
# Build de l'application
./gradlew build

# Exécution des tests
./gradlew test

# Lancement local
./gradlew bootRun
```

### Docker local
```bash
# Build de l'image
docker build -t cheerz-spring .

# Lancement du conteneur
docker run -p 8080:8080 cheerz-spring
```

## Endpoints disponibles

- `GET /` : Retourne "Hello Docker World"

## URL de l'application déployée

L'URL sera générée automatiquement par Cloud Run et affichée dans les logs du pipeline CI/CD.
Format : `https://cheerz-spring-app-[hash]-ew.a.run.app`

