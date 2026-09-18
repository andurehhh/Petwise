Petwise/
├── .github/
│   ├── workflows/
│   │   ├── mobile-ci.yml               # flutter analyze, flutter test, build check
│   │   └── mobile-release.yml          # build APK, distribute to Firebase or GitHub Releases
│   └── pull_request_template.md        # author checklist
│
├── docs/                               # role deliverables
│   ├── srs-lite.md                           # BA: requirements and user stories
│   ├── architecture.md                   # SA: 
│   ├── adr/                                      # ADRs (Architecture Design Records)
│   ├── test-plan.md                         # QA: widget tests, manual test journeys
│   ├── environments.md                 # DevOps: environment distributions
│   └── definition-of-done.md           # signed team quality standard
│
├── assets/                             # static assets
│   ├── images/
│   └── sounds/
│
├── android/                            # native Android wrapper & Gradle configs
├── ios/                                   # native iOS wrapper & Xcode project
│
├── lib/
│   ├── core/                           # shared platform foundations (replaces "platform/")
│   │   ├── config/                       # environment validation (.env reader, app config)
│   │   ├── constants/                 # asset strings, route paths
│   │   ├── network/                    # api_client.dart (Dio/Http), error handling, interceptors
│   │   ├── theme/                      # pet_theme.dart, typography, colors
│   │   └── widgets/                    # reusable UI primitives (petwise_app_bar, petwise_Navbar)
│   │
│   ├── features/                       # functions created per each module
│   │   ├── auth/                             # signin, signup, auth_provider, contracts
│   │   │   ├── data/                   
│   │   │   ├── presentation/           
│   │   │   └── providers/             
│   │   ├── pets/                             # pet profiles, cards, pen
│   │   │   ├── data/                   
│   │   │   ├── presentation/           
│   │   │   └── providers/              
│   │   ├── activities/                      # activity planner & logs
│   │   │   ├── data/                   
│   │   │   ├── presentation/           
│   │   │   └── providers/              
│   │   ├── health/                           # medication and vaccination trackings
│   │   │   ├── data/                   
│   │   │   ├── presentation/           
│   │   │   └── providers/              
│   │   └── analytics/                       # dashboard analytics, timelines
│   │       ├── data/                   
│   │       ├── presentation/           
│   │       └── providers/              
│   │
│   └── main.dart                       # dependency initialization
│
├── test/ #automated test cases
│   ├── unit/ #logic and functions tests
│   ├── widget/ #widget tests & UX/interaction checks
│   └── smoke/ #full user story tests
│
├── .env.example #API_BASE_URL, GOOGLE_MAPS_API_KEY, etc
├── .gitignore # ignores .env, .dart_tool/, build/, android/.gradle/
├── analysis_options.yaml                    
├── CONTRIBUTING.md #branch naming (feat/, fix/), PR template rules, squash merge
├── pubspec.yaml
└── README.md         
