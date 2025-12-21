# Analytics Integration Guide

## 🎯 Overview

The app now includes comprehensive analytics tracking using Firebase Analytics with automatic screen view tracking and custom event logging.

## 🔧 Setup

### 1. Analytics Service Configuration

The `AnalyticsService` is automatically initialized in `main.dart`:

```dart
// Initialize all services
await Future.wait([
  PerformanceService.initialize(),
  AnalyticsService.initialize(),
  StatePersistenceService.initialize(),
]);
```

### 2. Router Integration

Analytics observer is configured in `AppRouter` for automatic screen tracking:

```dart
static final GoRouter router = GoRouter(
  initialLocation: '/',
  observers: [
    AnalyticsService.observer, // Automatic screen view tracking
  ],
  routes: [
    // ... routes
  ],
);
```

## 📊 Available Analytics Events

### User Engagement
- `trackUserRegistration()` - User signs up
- `trackUserLogin()` - User logs in
- `trackProfileCompletion()` - Profile completion percentage
- `trackAppSessionStart()` - App session begins
- `tra24r 20ecembe**: Dt Updated-

**Lasices)

--s/best-practticdocs/analy.com/ogleebase.go(https://fires]icractst Pnalytics Be)
- [Aalytics/firebase_anckagesev/pa://pub.d(httpss Plugin]nalytic Aseer Fireba [Flutt
-tics)/analygle.com/docsase.gooreb/fittps:/tion](hmentacs Docunalyti Arebasees

- [Fisourcditional Re📚 Ady

## dailrics ey metnitor kevents
- Moon rsip conve- Set uiences
e custom audnfigur
- Codashboardnalytics rebase A
- Set up Fignitorind

### Moicy updatePrivacy pol] [ - 
alidatederties vrop [ ] User pts tested
-ustom even[ ] C enabled
- ctionics colle[ ] Analytion
- roductigured for pproject confebase irst
- [ ] Fnch Checkli Pre-Laut

###on Deploymen# 🚀 Productiment.

#elopng dev-time durients in real test evgView totics Debulynaase As
Use Firebng Event

### Testir123}
``` use profile_id:on: like,actiparams: {with ipe_action d: swEvent trackeNALYTICS] `
[A

``console: logged to ts areenalytics eve, all ann debug modebug Mode
I# D

##ebugging`

## 🐛 Dse);
``ed(falblllectionEnacsColytisetAnaance.ics.instytnalFirebaseAt 
awai collectionnalytics// Disable a
rtd:

```dacontrollen be fault but caed by deblis enaon cs collectitiAnaly Consent

### User logged
erta is nev dasitiveent
- Senol) are sing, num, bopes (Stra tyted datorOnly supps
- om keyved fr remoharactersecial c
- Spnitized: saomaticallye autrs arrametes payticalanon
All atianitiza SDat## liance

#cy & CompPriva🔒 n

## tioing intengoal` - Datationship_el`r
- sity nameer - University`der
- `univ User gen -
- `gender`+)0-34, 35, 25-29, 3 20-2419,8-anges (1Age r` - up
- `age_grolly set:aticas are autompertie user prollowingfoe 

Th Dimensionsstomte

### Cu  - ANR ra rate
 
   - Crashload times Screen  time
   -pp startupe**
   - AancPerform
4. **ion
ptadoVideo call -   
 re usageum featu  - Premie
 er usagilt**
   - Fdoption **Feature Arate

3.nse respoMessage  -   h rate
  - Matcion
 ons per sessactie 
   - Swipon ratempleticoile  Profnnel**
   -ng Fuati. **D30)

27, , ntion (Day 1 - User rete
  sessioner en views p   - Screon
sion duraties
   - Sctive Usersnthly Ay/Mo
   - Dailngagement**. **User Etor

1onis to MKey Metricard

### Dashboics 
## 📈 Analyt
```
');ilesh('/prof
context.puentiew evn vscreely logs a omaticalutis a
// Th
```dartvigation:
er naoutg GoRinked when uscally tracomatis are autScreen viewking
 View Traceen Scr##
```

#
);s',: 'serioualpGoationshiity',
  rel Universnfordersity: 'Stale',
  univr: 'femade,
  gen25:   age3',
: 'user12erIdies(
  usrtroperPrvice.setUseAnalyticsSeon
await ntatifor segmeerties user proprt
// Set rties
```daropeUser P
```

### 
  },
);x_age': 30,
    'ma1,'min_age': 2ge',
    ': 'age_ran_type   'filter{
 meters: 
  paraers',ced_filte: 'advanatureNamUsage(
  fetureFearackrvice.tlyticsSee
await Anature usagack fea
// Tr
);
r123',Id: 'use profile
 ',: 'like(
  actionkSwipeActionace.trrviccsSeytiawait Analtion
er acTrack ust
// daracking
```sic Event Tr## Ba
# Examples
 Usage## 🚀

snt evesh- App cra()` kAppCrash`trac metrics
- ormance Custom perf)` -ceMetric(rmanerfotrackP- `rs
 Erronce &rma

### Perforchases puoosthase()` - BrcrackBoostPuation
- `tlicilter app - Fge()`ilterUsackFe
- `trafeature usagGeneral )` - sage(ureUtrackFeat `Usage
-ature g

### Feviewinrofile  Pew()` -ileViof
- `trackPrentscall ev()` - Video allkVideoCg
- `tracsage sendinMesgeSent()` - `trackMessars match
-  use)` - WhenckMatch(ons
- `tra like actiuper, or s passn()` - Like,ipeActio- `trackSwents
Evg-Specific 
### Datins
ssion end - App send()`ckSessionE