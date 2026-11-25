# Ojie Quality Bar

Approved by Kurt on November 25, 2026.

A feature is **not done** when it works. It is done when it passes every pillar below and the evidence is shown. "It should work" is never evidence.

---

## How every feature is built

### Before code
1. **Write what "done" looks like.** Name the screens, the states and the rules in plain words.
2. **Design first.** Show mockups made from the Ojie Design System. Kurt approves them before any code.
3. **List the threats and failure cases** (see Pillar 1 and Pillar 5) for this feature.

### While coding
- Write the tests first, then the code (test-driven development).
- Use only design tokens for colors, fonts, spacing, radius and motion. No raw hex colors, magic numbers or one-off text styles in feature code.
- Keep files small and focused. One file has one job.

### Before saying "done" (Definition of Done)
- [ ] `flutter analyze` is clean and all tests pass (app tests, and `npx supabase test db` for database rules)
- [ ] Ran on Kurt's real phone, with screenshots in **light and dark mode**
- [ ] Checked with the **largest font size** setting and on a small screen
- [ ] Checked **offline** (airplane mode) and when coming back online
- [ ] Every state is handled: loading, empty, error, offline, success
- [ ] Security review and code review done; findings fixed or explained
- [ ] Privacy check: the coordinator sees only what the plan allows
- [ ] Evidence shown to Kurt (test output, screenshots), not just "tapos na"

---

## The 11 pillars

### 1. Security (also after deployment)
Assume the app is live and someone is trying to abuse it.
- **Every table** has RLS on, explicit grants, and policies for each action. No table is reachable without a policy.
- **PowerSync sync streams** send each user only the rows they may see. They must match RLS.
- **Database tests (pgTAP)** prove the rules: a student cannot read another student's data; a coordinator cannot read moods or unsubmitted journal entries; an unverified coordinator sees nothing; anonymous users see nothing.
- **Never trust the phone.** Anything that matters (roles, verification, approvals, signatures, locked weeks) is decided or checked on the server.
- **Secrets:** only public values in the app. Server secrets live in Supabase secrets or `supabase/functions/.env`. Never in Git.
- **Inputs are validated** on the server (lengths, types, allowed values), not only in the UI.
- **Edge Functions** check the caller's identity and role on every request, and limit how often they can be called.
- **Files** in Storage are private by default; access goes through policies or short-lived signed URLs.
- **Before production:** release signing key kept safe and backed up, Supabase leaked-password and abuse settings on, API keys restricted where possible, dependencies checked for known issues.

Ojie-specific threats to always think about:
- A student editing time records to fake hours, or changing a locked (signed) week
- A student pretending to be a coordinator
- Changing the phone's clock while offline to fake a time-in
- A coordinator seeing more than the consent screen promised
- A join code being guessed or shared to join the wrong batch
- Someone else reading a student's private incident log or journal on a shared phone

### 2. Design (UI)
No generic, default-looking screens ("AI slop").
- One **Ojie Design System**: color palette from the mascot (charcoal, orange, cream) built with color theory and checked for contrast in light and dark mode; a deliberate, professional type pairing; a spacing scale; radius, elevation and icon rules; and reusable components.
- Clear **visual hierarchy** on every screen: one main action, then secondary content.
- Consistent **layout structure** and spacing rhythm across all screens.
- Responsive: phones of all sizes, and a wider layout for tablets where the plan says so.
- Ojie the mascot is used with intent (moments of help, celebration, empty states), not as decoration everywhere.
- **Icons are professional, never childish**: one icon set across the whole app, same stroke and size. No emoji in buttons, labels, tags or navigation. Emotion comes from Ojie's poses and illustrations drawn in his style, not emoji.

### 3. Experience (UX)
- The daily actions (time in, time out, check-in) take **as few taps as possible** and work with one hand.
- The next step is always obvious. No dead ends.
- Feedback for every action (pressed, saving, saved, failed).
- Ask for information only when it is needed; let users skip and come back.
- Destructive actions ask for confirmation or can be undone.

### 4. Motion
- Animations have a purpose: show where something came from, confirm an action, or celebrate.
- Short and smooth (most transitions under 300 ms), never blocking the user.
- Respect the phone's "reduce animations" setting.

### 5. Reliability and data integrity
- **A time-in is never lost**: saved on the phone first, synced later, survives app close and phone restart.
- **No double entries**: client-made UUIDs, safe retries.
- Time is recorded with both the phone time and the server time once synced; large differences are flagged, not hidden.
- Edited entries are always marked edited; signed weeks are locked (enforced on the server).
- Every sync error is visible to the user in plain words and recoverable.

### 6. Performance (budget phones, weak data)
- Target a budget Android phone (like the Infinix X6885) on slow mobile data.
- Fast start; the home screen opens without waiting for the network.
- Smooth scrolling (no dropped frames on long lists).
- Small release app size; images compressed before upload; photos upload on Wi-Fi unless the user allows mobile data.
- Careful with battery: no background location, no constant polling.

### 7. Accessibility
- Text contrast meets WCAG AA (4.5:1 for normal text, 3:1 for large text and icons).
- Tap targets at least 48 × 48 dp.
- Layouts still work at the largest system font size.
- Screen reader labels on icons and images; meaning is never shown by color alone.

### 8. Privacy and the law
- Follows the Data Privacy Act of 2012 (RA 10173) and the privacy rules in the feature plan.
- Collect only what a feature uses. Consent screens say exactly what is shared, in plain words.
- No personal data or journal text in analytics or crash reports.
- Users can download and delete their data.

### 9. Every state and every word
- Each screen designs its **loading, empty, error, offline and success** states, not only the happy path.
- Copy follows Ojie's voice: casual Taglish (or the chosen language), kind, never mocking the student.
- Errors say what happened and what to do next.

### 10. Testing
- Unit tests for rules (hours, breaks, streaks, projected end date).
- Widget tests for screens and their states.
- Integration tests for the main flows (sign in, time in/out offline, check-in).
- Database tests (pgTAP) for every privacy and security rule.
- Bugs get a test that fails first, then the fix.

### 11. Maintainability
- Follow the folder structure in `CLAUDE.md`: `core/` for shared code, `features/<name>/{data,domain,presentation}`.
- Riverpod for state; no global mutable state in feature code.
- Clear names, small files, no dead code, no copy-paste between features.
- Every database change is a new migration.
