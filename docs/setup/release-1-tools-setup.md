# Ojie: Pag-connect ng Tools para sa Release 1

Gabay ito na susundan mo nang isa-isa. Lagyan mo ng ✔ ang bawat checkbox kapag tapos na.

**Tatlong rules bago magsimula:**

1. 🔒 **Huwag i-paste sa chat ang passwords at secret keys.** Ilagay mo lang sila sa `.env` file (nasa Step 1.6 kung paano) o sa password manager mo.
2. 📩 Kapag nakita mo ang "**Sabihin kay Claude**", ibalita mo sa akin bago ka tumuloy. May gagawin ako sa parteng iyon.
3. ❓ Kapag iba ang lumabas sa screen mo kaysa sa nakasulat dito, mag-screenshot ka o kopyahin ang error at ipakita sa akin. Madalas magpalit ng itsura ang mga website na ito.

Gumamit ng **iisang Google account** para sa lahat ng ito (Firebase, Google Cloud, Play Console), para magkakakonekta ang lahat.

---

## Step 0: Simulan na ang Google Play Console (ito ang matagal)

Uunahin natin ito kasi **ilang araw** bago ma-verify ang account mo. Habang naghihintay, gawin mo ang Steps 1 hanggang 6.

- [ ] Pumunta sa **play.google.com/console/signup**
- [ ] Piliin ang **"Yourself"** (personal account). Ang "Organization" ay humihingi ng D-U-N-S number ng kumpanya, kaya hindi muna iyon.
- [ ] Sagutan ang form: pangalan, address at contact details
- [ ] Magbayad ng **$25** (isang beses lang)
- [ ] Gawin ang **identity verification** gamit ang valid government ID
- [ ] Kung hingin, i-verify na may hawak kang **totoong Android phone** gamit ang Play Console app

✅ **Tapos na ito kapag** naka-submit na ang verification. Hintayin ang email ng Google, at saka natin itutuloy sa Step 7.

---

## Step 1: Supabase (database at login)

### 1.1 Gumawa ng account at project
- [ ] Pumunta sa **supabase.com**, pindutin ang **Start your project**, at mag-sign in gamit ang **GitHub**
- [ ] Gumawa ng organization: pangalan **Ojie**, plan **Free**
- [ ] Gumawa ng **New project**:
  - Name: `ojie`
  - Database password: pindutin ang **Generate a password**, at **i-save ito sa password manager.** Kailangan natin ito mamaya.
  - Region: **Southeast Asia (Singapore)**
- [ ] Pindutin ang **Create new project** at hintaying matapos (mga 2 minuto)

### 1.2 Kunin ang mga value
- [ ] Sa project, pindutin ang **Connect** sa itaas, o pumunta sa **Project Settings → API Keys / Data API**
- [ ] Hanapin ang **Project URL** (ganito ang itsura: `https://abcdefgh.supabase.co`)
- [ ] Hanapin ang **publishable key** o **anon key**. Okay lang na nasa app ito.
- [ ] Hanapin ang **Project Reference ID**. Ito ang `abcdefgh` na parte ng URL.

> ⚠️ **Huwag** gamitin o kopyahin ang **service_role key** o **secret key**. Hindi ito dapat mapunta sa app.

### 1.3 Gawin ang `.env` file
- [ ] Sa folder na `C:\Users\kurts\Claude\Ojie`, kopyahin ang `.env.example` at pangalanan ang kopya na `.env`
- [ ] Buksan ang `.env` at punan ang:
  ```
  SUPABASE_URL=https://abcdefgh.supabase.co
  SUPABASE_ANON_KEY=(yung publishable/anon key)
  ```
- [ ] I-save. Hindi ito mapupunta sa GitHub kasi naka-ignore ito.

### 1.4 Ikonekta ang folder sa Supabase
Buksan ang terminal sa `C:\Users\kurts\Claude\Ojie` at patakbuhin:
- [ ] `npx supabase login`. Magbubukas ang browser; i-approve mo lang.
- [ ] `npx supabase link --project-ref abcdefgh`. Palitan ang `abcdefgh` ng Project Reference ID mo. I-type ang database password kapag hiningi.

### 1.5 Ihanda ang Docker
- [ ] Buksan ang **Docker Desktop** at hintaying maging "running" ito

📩 **Sabihin kay Claude:** "Tapos na ang Supabase." Ako na ang magpapatakbo ng local database at magche-check kung konektado.

---

## Step 2: Firebase (notifications, crash reports at analytics)

### 2.1 Gumawa ng project
- [ ] Pumunta sa **console.firebase.google.com** at pindutin ang **Create a project**
- [ ] Name: **Ojie**
- [ ] **Google Analytics:** i-on, at piliin o gumawa ng Analytics account
- [ ] Hintaying matapos

### 2.2 Crashlytics
Walang kailangang gawin. Kusang nag-o-on ang Crashlytics kapag nagpadala ang app ng unang crash report (Step 9, Test 4).

### 2.3 I-install ang mga CLI tool
Sa terminal:
- [ ] `npm install -g firebase-tools`
- [ ] `firebase login`. Gamitin ang parehong Google account.
- [ ] `dart pub global activate flutterfire_cli`
- [ ] Kapag sinabi ng terminal na wala sa PATH ang `Pub\Cache\bin`, idagdag ang folder na ito sa Windows PATH, at saka isara at buksan ulit ang terminal:
  `C:\Users\kurts\AppData\Local\Pub\Cache\bin`
- [ ] Patunayan na gumagana: dapat may lumabas na version number kapag pinatakbo mo ang `flutterfire --version`

📩 **Sabihin kay Claude:** "Tapos na ang Firebase" at ibigay ang **Project ID** ng Firebase (halimbawa `ojie-12345`). Hindi ito secret. Ako na ang magpapatakbo ng `flutterfire configure` para ikonekta ang app.

---

## Step 3: Google Sign-In

Hindi na kailangan ng bagong project dito, kasi ang Firebase project mo ay isa na ring Google Cloud project.

### 3.1 Kunin ang SHA-1
📩 **Sabihin kay Claude:** "Kailangan ko ang SHA-1." Ako ang kukuha nito mula sa computer mo. Parang fingerprint ito ng app mo.

### 3.2 I-setup ang consent screen
- [ ] Pumunta sa **console.cloud.google.com**
- [ ] Sa itaas, piliin ang project na **kapareho ng Firebase project** mo
- [ ] Pumunta sa **Google Auth Platform** (o **APIs & Services → OAuth consent screen**)
- [ ] Punan ang form:
  - App name: **Ojie**
  - User support email: ang email mo
  - Audience: **External**
  - Contact email: ang email mo
- [ ] I-save
- [ ] Sa **Audience**, idagdag ang sarili mong email bilang **Test user**, o pindutin ang **Publish app**. Puwede itong i-publish nang walang review, kasi pangalan at email lang ang hinihingi natin.

### 3.3 Gumawa ng Web client (para sa Supabase)
- [ ] Pumunta sa **Clients** (o **Credentials**), pindutin ang **Create client**, at piliin ang **Web application**
- [ ] Name: `Ojie Supabase`
- [ ] Sa **Authorized redirect URIs**, idagdag ito (palitan ang `abcdefgh` ng Supabase Reference ID mo):
  `https://abcdefgh.supabase.co/auth/v1/callback`
- [ ] Pindutin ang **Create**
- [ ] Kopyahin ang **Client ID** at **Client secret**. I-save ang secret sa password manager mo.
- [ ] Sa `.env`, idagdag: `GOOGLE_WEB_CLIENT_ID=(yung Client ID)`

### 3.4 Gumawa ng Android client
- [ ] Pindutin ulit ang **Create client** at piliin ang **Android**
- [ ] Package name: `ph.ojie.app`
- [ ] SHA-1: ang ibibigay ko sa Step 3.1
- [ ] Pindutin ang **Create**

### 3.5 I-on ang Google login sa Supabase
- [ ] Sa Supabase dashboard, pumunta sa **Authentication → Sign In / Providers → Google**
- [ ] I-enable ito
- [ ] Ilagay ang **Client ID** at **Client secret** mula sa Step 3.3
- [ ] I-save

📩 **Sabihin kay Claude:** "Tapos na ang Google Sign-In."

---

## Step 4: PowerSync (offline sync)

### 4.1 Database user (hindi na kailangan)
Kusang gumagawa ang **Connect Supabase** ng PowerSync (Step 4.3) ng sarili nitong database user. Kailangan lang na **may kahit isang table na** sa Supabase bago kumonekta. Ang publication na `powersync` ay galing sa migration ng project.

### 4.2 Gumawa ng account at instance
- [ ] Pumunta sa **powersync.com**, pindutin ang **Sign up**, at mag-sign in gamit ang **GitHub**
- [ ] Gumawa ng project na **Ojie**. Kusa itong gagawa ng dalawang instance: **Development** (gagamitin natin ngayon) at **Production** (para sa pilot balang araw).
- [ ] Region: **us** (ito ang pinili natin)

### 4.3 Ikonekta sa Supabase
- [ ] Sa **Development** instance, pumunta sa **Database Connection** at pindutin ang **Connect Supabase**
- [ ] Piliin ang Supabase project na **ojie**. Kapag "No tables detected" ang lumabas, kailangan munang mag-push ng migration na may table, at saka pindutin ang **Refresh Project**.
- [ ] Hintaying maging **Complete** ang status
- [ ] Pindutin ang **Configure Sync**, i-paste ang laman ng [powersync/sync-rules.yaml](../../powersync/sync-rules.yaml), at saka **Validate** at **Deploy**

### 4.4 I-on ang Supabase login sa PowerSync
- [ ] Sa instance settings, pumunta sa **Client Auth**
- [ ] I-check ang **Use Supabase Auth** (o katulad na option), at sundan ang hinihingi nito
- [ ] I-save at i-deploy

### 4.5 Kunin ang URL
- [ ] Kopyahin ang **Instance URL** (ganito ang itsura: `https://xxxx.powersync.journeyapps.com`)
- [ ] Sa `.env`, idagdag: `POWERSYNC_URL=(yung URL)`

📩 **Sabihin kay Claude:** "Tapos na ang PowerSync." Ako ang gagawa ng sync rules at ituturo ko kung saan ito ilalagay.

> Kapag nag-error ang **Test connection**, kopyahin ang error at ipakita sa akin. Ito ang pinakamadalas magkaproblema.

---

## Step 5: GitHub Actions (automatic checks)

**Wala kang gagawin dito.** Ako ang magsusulat ng workflow. Pagkatapos kong mag-push:
- [ ] Buksan ang **github.com/KurtSalut29/Ojie** at pumunta sa tab na **Actions**
- [ ] Dapat may **berdeng ✓** ang huling run

---

## Step 6: Website (privacy policy)

Ako muna ang gagawa ng `website/` files (landing page at privacy policy). Ikaw ang **magbabasa at mag-a-approve ng privacy policy**, kasi ikaw ang mananagot dito.

Kapag handa na ang files:
- [ ] Pumunta sa **dash.cloudflare.com** at gumawa ng account
- [ ] Pumunta sa **Workers & Pages**, pindutin ang **Create**, at piliin ang **Pages**, saka ang **Connect to Git**
- [ ] I-connect ang GitHub at piliin ang repo na **KurtSalut29/Ojie**
- [ ] Build settings:
  - Framework preset: **None**
  - Build command: (iwanang blangko)
  - Build output directory: `website`
- [ ] Pindutin ang **Save and Deploy**
- [ ] Kopyahin ang URL (halimbawa `ojie.pages.dev`)

📩 **Sabihin kay Claude** ang URL.

---

## Step 7: Google Play Console (kapag na-verify na ang account mo)

- [ ] Pindutin ang **Create app**
  - App name: **Ojie**
  - Default language: English
  - App or game: **App**
  - Free or paid: **Free**
- [ ] I-check ang mga declaration at pindutin ang **Create app**

📩 **Sabihin kay Claude:** "Na-create na ang app sa Play Console." Ituturo ko ang setup ng closed testing at kung paano mag-upload ng unang build.

> Pagkatapos ng unang upload, kakailanganin nating idagdag ang **SHA-1 ng Play App Signing** sa Google Cloud (ulitin ang Step 3.4), para gumana rin ang Google Sign-In sa version na galing sa Play Store.

---

## Step 8: Ihanda ang phone mo para sa testing

- [ ] Sa Android phone, pumunta sa **Settings → About phone** at pindutin nang **7 beses** ang **Build number**. Magiging developer mode ang phone.
- [ ] Pumunta sa **Settings → Developer options** at i-on ang **USB debugging**
- [ ] Ikonekta ang phone sa computer gamit ang USB cable, at pindutin ang **Allow** sa phone
- [ ] Sa terminal, patakbuhin ang `flutter devices`. Dapat makita doon ang phone mo.

---

## Step 9: Ang final test (sabay nating gagawin)

Gagawa ako ng pansamantalang test screen. Susubukan mo ito sa phone mo:

- [ ] **Test 1:** Nakakapag-login gamit ang Google
- [ ] **Test 2:** I-on ang airplane mode, pindutin ang "Save test", at i-off ulit ang airplane mode. Dapat lumabas ang data sa Supabase.
- [ ] **Test 3:** May dumarating na push notification galing sa Firebase
- [ ] **Test 4:** Pindutin ang "Test crash". Dapat lumabas ang crash sa Firebase Crashlytics (puwedeng abutin nang ilang minuto).

Kapag pasado ang lahat ng apat, buburahin ko ang test screen, at **saka tayo magsisimula sa features.** 🎉
