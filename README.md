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

La pipeline GitHub Actions comprend 2 jobs principaux :

### 1. Build & Test (build-and-test)

- Exécution à chaque push sur toutes les branches
- Récupération du code source
- Configuration de Java 17 (Temurin)
- Rendre le wrapper Gradle exécutable
- Compilation et exécution des tests via ./gradlew build --no-daemon

### 2. Dockerize & Deploy to Cloud Run (docker-deploy)

- S’exécute uniquement sur la branche master (déploiement conditionnel)
- Dépend du succès du job build-and-test
- Récupération du code source
- Authentification auprès de Google Cloud avec la clé stockée dans GCP_SA_KEY
- Installation et configuration du SDK Google Cloud (gcloud)
- Configuration de Docker pour pousser vers le Google Artifact Registry
- Construction de l’image Docker taggée avec le SHA du commit
- Push de l’image Docker vers Artifact Registry dans le dépôt correspondant
- Déploiement sur Cloud Run avec l’image poussée, dans la région et projet configurés
- Le service est déployé en mode “managed” avec accès public (--allow-unauthenticated)

## Choix de la plateforme de déploiement : Google Cloud Run

**Justification du choix pour ce test technique :**

Parmi les options disponibles (CloudRun, Cluster GKE, VM avec Java, AppEngine), j'ai choisi **Google Cloud Run** pour les raisons suivantes :

### Pourquoi Cloud Run était optimal pour ce test technique :

1. **Simplicité de mise en œuvre** : Cloud Run permet un déploiement direct depuis une image Docker sans configuration complexe d'infrastructure, ce qui est parfait pour démontrer rapidement une pipeline CI/CD fonctionnelle.

2. **Coût minimal** : Pour un test technique, Cloud Run offre un modèle "pay-per-use", évitant les coûts fixes d'une VM ou d'un cluster GKE qui tourneraient en permanence.

3. **Intégration native avec le CI/CD** : L'intégration avec GitHub Actions et Artifact Registry est straightforward, permettant de se concentrer sur la qualité de la pipeline plutôt que sur la complexité du déploiement.


### Comparaison avec les autres options :

- **Cluster GKE** : Trop complexe pour une simple application Hello World, nécessiterait la configuration d'un cluster Kubernetes
- **VM avec Java** : Gestion manuelle de l'infrastructure, pas de scaling automatique, coûts fixes
- **App Engine** : Moins de contrôle sur l'environnement Docker, contraintes sur la structure de l'application

**En résumé** : Cloud Run était le choix optimal car il permet de démontrer un pipeline CI/CD moderne et efficace tout en minimisant la complexité opérationnelle, ce qui est exactement ce qu'on attend d'un test technique bien conçu.

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

gcloud iam service-accounts add-iam-policy-binding 1057396878533-compute@developer.gserviceaccount.com \
    --member="serviceAccount:github-deployer@cheerz-spring.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

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
Format : `https://cheerz-spring-app-[hash].europe-west1.run.app`

## Améliorations possibles

### Optimisations de base

1. **Cache des dépendances**
   - Mise en cache des dépendances Gradle pour réduire les temps de build
   - Cache des layers Docker pour accélérer la construction des images

2. **Tests et qualité**
   - Ajout de tests d'intégration après déploiement
   - Analyse de la qualité du code (SonarQube)
   - Vérification de la couverture de tests

3. **Sécurité**
   - Scan des vulnérabilités sur les images Docker
   - Analyse des dépendances pour détecter les failles de sécurité
   - Utilisation de Workload Identity au lieu de clés JSON

### Améliorations du déploiement

4. **Gestion des environnements**
   - Déploiement sur plusieurs environnements (dev, staging, prod)
   - Configuration spécifique par environnement
   - Promotion automatique entre environnements

5. **Monitoring**
   - Ajout de health checks
   - Monitoring des métriques de base (CPU, mémoire, requêtes)
   - Alertes en cas de problème

6. **Rollback et versioning**
   - Stratégie de rollback automatique
   - Tagging des versions
   - Historique des déploiements

Ces améliorations permettraient de rendre la pipeline plus robuste et adapté à un environnement de production.
