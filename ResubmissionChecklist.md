# Nailiro Log Resubmission Checklist

## App Store Connect Metadata

Use `AppStoreMetadata.json` for the values to paste into App Store Connect.

- App name: `Nailiro Log`
- Subtitle: `Nail photos and color notes`
- Keywords: `nails,nail log,nail memo,beauty,color,design,photo,salon,self care,style`
- Upload screenshots from `screenshots/`
- Paste the review notes from `AppReviewReply.md` into App Review Information

## Build

Pushing to `master` runs `.github/workflows/build.yml`.

The workflow:

- Generates the Xcode project with XcodeGen
- Archives the iOS app
- Exports the build
- Uploads the build to App Store Connect

After the build appears in App Store Connect, select the new build for the version and submit it for review.

## Safety Check

The app and screenshots were changed from a medical-style app to a beauty note app:

- No medical reference tab
- No disease or condition names shown to users
- No health measurement wording
- No diagnosis or treatment wording
- Camera permission explains nail photos and color notes
