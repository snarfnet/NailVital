import base64
import hashlib
import json
import os
import re
import sys
import time
from pathlib import Path

import jwt
import requests


BUNDLE_ID = os.environ.get("BUNDLE_ID", "com.snarfnet.nailvital")
APP_VERSION = os.environ.get("APP_VERSION", "1.0")
METADATA_PATH = Path(os.environ.get("METADATA_PATH", "AppStoreMetadata.json"))
SCREENSHOT_DIR = Path(os.environ.get("SCREENSHOT_DIR", "screenshots"))
BUILD_NUMBER = os.environ.get("BUILD_NUMBER", "")
P8_PATH = Path(os.environ.get("ASC_P8_PATH", "/tmp/AuthKey.p8"))
SCREENSHOT_GROUPS = [
    ("APP_IPHONE_67", [f"screenshot_{index:02d}.png" for index in range(1, 4)]),
    ("APP_IPAD_PRO_3GEN_129", [f"ipad_screenshot_{index:02d}.png" for index in range(1, 4)]),
]


def env_first(*names):
    for name in names:
        value = os.environ.get(name)
        if value:
            return value
    return ""


KEY_ID = env_first("ASC_API_KEY_ID", "ASC_KEY_ID")
ISSUER_ID = env_first("ASC_API_ISSUER_ID", "ASC_ISSUER_ID")


def write_key_file():
    if P8_PATH.exists():
        return
    key_content = env_first("ASC_PRIVATE_KEY", "ASC_API_KEY")
    key_base64 = env_first("ASC_API_KEY_CONTENT", "ASC_API_KEY_BASE64")
    if key_content:
        P8_PATH.write_text(key_content.replace("\\n", "\n"), encoding="utf-8")
        return
    if key_base64:
        P8_PATH.write_bytes(base64.b64decode(key_base64))
        return
    raise RuntimeError("Missing App Store Connect private key secret.")


def make_token():
    now = int(time.time())
    private_key = P8_PATH.read_text(encoding="utf-8")
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        private_key,
        algorithm="ES256",
        headers={"kid": KEY_ID, "typ": "JWT"},
    )


def headers():
    return {"Authorization": f"Bearer {make_token()}", "Content-Type": "application/json"}


def api(method, path, **kwargs):
    for attempt in range(6):
        response = requests.request(
            method,
            f"https://api.appstoreconnect.apple.com/v1{path}",
            headers=headers(),
            timeout=180,
            **kwargs,
        )
        if response.status_code not in (401, 429, 500, 502, 503, 504):
            return response
        print(f"{method} {path}: retry {attempt + 1}/6 status={response.status_code}")
        time.sleep(20)
    return response


def api_json(method, path, **kwargs):
    response = api(method, path, **kwargs)
    try:
        body = response.json()
    except Exception:
        body = {}
    return response, body


def require_ok(response, label):
    if response.status_code not in (200, 201, 204):
        raise RuntimeError(f"{label} failed {response.status_code}: {response.text[:1000]}")


def list_all(path):
    rows = []
    next_path = path
    while next_path:
        response, body = api_json("GET", next_path)
        require_ok(response, f"List {next_path}")
        rows.extend(body.get("data", []))
        next_url = body.get("links", {}).get("next")
        next_path = next_url.split("/v1", 1)[1] if next_url else None
    return rows


def load_metadata():
    return json.loads(METADATA_PATH.read_text(encoding="utf-8"))


def find_app_id():
    apps = list_all(f"/apps?filter[bundleId]={BUNDLE_ID}&limit=10")
    if not apps:
        raise RuntimeError(f"No App Store Connect app found for {BUNDLE_ID}.")
    app = apps[0]
    attrs = app["attributes"]
    print(f"App: {attrs.get('name')} / {attrs.get('bundleId')} / {app['id']}")
    return app["id"]


def find_version(app_id):
    versions = list_all(f"/apps/{app_id}/appStoreVersions?filter[platform]=IOS&limit=200")
    for version in versions:
        attrs = version.get("attributes", {})
        if attrs.get("versionString") == APP_VERSION:
            print(f"Version {APP_VERSION}: {version['id']} state={attrs.get('appStoreState')}")
            return version["id"]
    response, body = api_json("POST", "/appStoreVersions", json={
        "data": {
            "type": "appStoreVersions",
            "attributes": {"platform": "IOS", "versionString": APP_VERSION},
            "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
        }
    })
    require_ok(response, "Create version")
    print(f"Created version {APP_VERSION}: {body['data']['id']}")
    return body["data"]["id"]


def ensure_version_localizations(version_id):
    rows = list_all(f"/appStoreVersions/{version_id}/appStoreVersionLocalizations?limit=200")
    existing = {row["attributes"]["locale"]: row for row in rows}
    for locale in ("en-US", "ja"):
        if locale in existing:
            continue
        response, body = api_json("POST", "/appStoreVersionLocalizations", json={
            "data": {
                "type": "appStoreVersionLocalizations",
                "attributes": {"locale": locale},
                "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}}},
            }
        })
        require_ok(response, f"Create localization {locale}")
        existing[locale] = body["data"]
    return existing


def update_version_metadata(version_id, metadata):
    attrs = {
        "description": metadata["description"],
        "keywords": metadata["keywords"],
        "promotionalText": metadata["promotionalText"],
        "supportUrl": "https://snarfnet.github.io/",
        "marketingUrl": "https://snarfnet.github.io/",
        "whatsNew": "Reworked as a beauty nail color log. Updated wording, screenshots, and app review notes.",
    }
    for locale, loc in ensure_version_localizations(version_id).items():
        response = api("PATCH", f"/appStoreVersionLocalizations/{loc['id']}", json={
            "data": {"type": "appStoreVersionLocalizations", "id": loc["id"], "attributes": attrs}
        })
        if response.status_code == 409:
            fallback = {key: value for key, value in attrs.items() if key != "whatsNew"}
            response = api("PATCH", f"/appStoreVersionLocalizations/{loc['id']}", json={
                "data": {"type": "appStoreVersionLocalizations", "id": loc["id"], "attributes": fallback}
            })
        require_ok(response, f"Update metadata {locale}")
        print(f"Metadata updated: {locale}")


def update_app_info(app_id, metadata):
    response, body = api_json("GET", f"/apps/{app_id}/appInfos?limit=10")
    require_ok(response, "Get app infos")
    app_infos = body.get("data", [])
    if not app_infos:
        print("No appInfo found, skipping app name/subtitle update.")
        return
    app_info_id = app_infos[0]["id"]

    response = api("PATCH", f"/apps/{app_id}", json={
        "data": {
            "type": "apps",
            "id": app_id,
            "attributes": {"contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT"},
        }
    })
    if response.status_code not in (200, 204, 409):
        require_ok(response, "Content rights")

    update_age_rating(app_info_id)

    response, body = api_json("GET", f"/appInfos/{app_info_id}/appInfoLocalizations?limit=200")
    require_ok(response, "Get app info localizations")
    existing = {row["attributes"]["locale"]: row for row in body.get("data", [])}
    for locale in ("en-US", "ja"):
        loc = existing.get(locale)
        if not loc:
            response, created = api_json("POST", "/appInfoLocalizations", json={
                "data": {
                    "type": "appInfoLocalizations",
                    "attributes": {"locale": locale},
                    "relationships": {"appInfo": {"data": {"type": "appInfos", "id": app_info_id}}},
                }
            })
            require_ok(response, f"Create app info localization {locale}")
            loc = created["data"]
        response = api("PATCH", f"/appInfoLocalizations/{loc['id']}", json={
            "data": {
                "type": "appInfoLocalizations",
                "id": loc["id"],
                "attributes": {
                    "name": metadata["appName"],
                    "subtitle": metadata["subtitle"],
                    "privacyPolicyUrl": "https://snarfnet.github.io/privacy.html",
                },
            }
        })
        require_ok(response, f"Update app info {locale}")
        print(f"App info updated: {locale}")


def update_age_rating(app_info_id):
    string_keys = [
        "alcoholTobaccoOrDrugUseOrReferences",
        "contests",
        "gamblingSimulated",
        "gunsOrOtherWeapons",
        "medicalOrTreatmentInformation",
        "profanityOrCrudeHumor",
        "sexualContentGraphicAndNudity",
        "sexualContentOrNudity",
        "horrorOrFearThemes",
        "matureOrSuggestiveThemes",
        "violenceCartoonOrFantasy",
        "violenceRealisticProlongedGraphicOrSadistic",
        "violenceRealistic",
    ]
    bool_keys = [
        "messagingAndChat",
        "gambling",
        "parentalControls",
        "ageAssurance",
        "userGeneratedContent",
        "healthOrWellnessTopics",
        "lootBox",
    ]
    attrs = {key: "NONE" for key in string_keys}
    attrs.update({key: False for key in bool_keys})
    attrs["advertising"] = False
    attrs["unrestrictedWebAccess"] = False
    response = api("PATCH", f"/ageRatingDeclarations/{app_info_id}", json={
        "data": {"type": "ageRatingDeclarations", "id": app_info_id, "attributes": attrs}
    })
    if response.status_code in (200, 204, 409):
        print(f"Age rating updated/skipped: {response.status_code}")
        return
    require_ok(response, "Age rating")


def update_review_detail(version_id, metadata):
    attrs = {
        "contactFirstName": "Tokyo",
        "contactLastName": "Nasu",
        "contactEmail": "tokyonasu@yahoo.co.jp",
        "contactPhone": "+81 80-2368-9194",
        "demoAccountRequired": False,
        "demoAccountName": "",
        "demoAccountPassword": "",
        "notes": metadata["reviewNotes"],
    }
    response, body = api_json("GET", f"/appStoreVersions/{version_id}/appStoreReviewDetail")
    require_ok(response, "Get review detail")
    if body.get("data"):
        detail_id = body["data"]["id"]
        response = api("PATCH", f"/appStoreReviewDetails/{detail_id}", json={
            "data": {"type": "appStoreReviewDetails", "id": detail_id, "attributes": attrs}
        })
        require_ok(response, "Update review detail")
        print("Review detail updated")
        return
    response = api("POST", "/appStoreReviewDetails", json={
        "data": {
            "type": "appStoreReviewDetails",
            "attributes": attrs,
            "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}}},
        }
    })
    require_ok(response, "Create review detail")
    print("Review detail created")


def wait_for_latest_build(app_id):
    for attempt in range(90):
        query = f"/builds?filter[app]={app_id}&limit=200"
        if BUILD_NUMBER:
            query += f"&filter[version]={BUILD_NUMBER}"
        response, body = api_json("GET", query)
        require_ok(response, "List builds")
        valid_builds = []
        for build in body.get("data", []):
            attrs = build["attributes"]
            version = attrs.get("version")
            state = attrs.get("processingState")
            print(f"Build {version}: {state}")
            if state == "VALID":
                valid_builds.append(build)
        if BUILD_NUMBER and valid_builds:
            return valid_builds[0]["id"]
        if valid_builds:
            def build_number(item):
                try:
                    return int(item["attributes"].get("version", "0"))
                except ValueError:
                    return 0
            return max(valid_builds, key=build_number)["id"]
        print(f"Waiting for valid build {attempt + 1}/90")
        time.sleep(30)
    raise RuntimeError("No valid build found.")


def print_builds(app_id):
    response, body = api_json("GET", f"/builds?filter[app]={app_id}&limit=200")
    require_ok(response, "List builds")
    rows = body.get("data", [])
    def sort_key(item):
        uploaded = item.get("attributes", {}).get("uploadedDate") or ""
        return uploaded
    for build in sorted(rows, key=sort_key, reverse=True):
        attrs = build["attributes"]
        print(
            "Build "
            f"{attrs.get('version')} / "
            f"{attrs.get('processingState')} / "
            f"{attrs.get('uploadedDate')} / "
            f"{build['id']}"
        )


def assign_build(version_id, build_id):
    response = api("PATCH", f"/builds/{build_id}", json={
        "data": {"type": "builds", "id": build_id, "attributes": {"usesNonExemptEncryption": False}}
    })
    if response.status_code not in (200, 204, 409):
        require_ok(response, "Encryption declaration")
    response = api("PATCH", f"/appStoreVersions/{version_id}/relationships/build", json={
        "data": {"type": "builds", "id": build_id}
    })
    if response.status_code not in (200, 204, 409):
        require_ok(response, "Assign build")
    print(f"Build assigned/skipped: {response.status_code}")


def upload_screenshots(version_id):
    for loc in ensure_version_localizations(version_id).values():
        locale = loc["attributes"]["locale"]
        print(f"Screenshots for {locale}")
        sets = list_all(f"/appStoreVersionLocalizations/{loc['id']}/appScreenshotSets?limit=200")
        existing_sets = {
            screenshot_set["attributes"]["screenshotDisplayType"]: screenshot_set["id"]
            for screenshot_set in sets
        }
        for screenshot_set in sets:
            for screenshot in list_all(f"/appScreenshotSets/{screenshot_set['id']}/appScreenshots?limit=200"):
                api("DELETE", f"/appScreenshots/{screenshot['id']}")
        for display_type, filenames in SCREENSHOT_GROUPS:
            files = [SCREENSHOT_DIR / filename for filename in filenames]
            for file in files:
                if not file.exists():
                    raise RuntimeError(f"Missing screenshot: {file}")
            set_id = existing_sets.get(display_type)
            if not set_id:
                response, body = api_json("POST", "/appScreenshotSets", json={
                    "data": {
                        "type": "appScreenshotSets",
                        "attributes": {"screenshotDisplayType": display_type},
                        "relationships": {
                            "appStoreVersionLocalization": {
                                "data": {"type": "appStoreVersionLocalizations", "id": loc["id"]}
                            }
                        },
                    }
                })
                require_ok(response, f"Create screenshot set {display_type}")
                set_id = body["data"]["id"]
            for file in files:
                upload_screenshot(set_id, file)


def upload_screenshot(set_id, file):
    data = file.read_bytes()
    checksum = hashlib.md5(data).hexdigest()
    response, body = api_json("POST", "/appScreenshots", json={
        "data": {
            "type": "appScreenshots",
            "attributes": {"fileName": file.name, "fileSize": len(data)},
            "relationships": {"appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}},
        }
    })
    require_ok(response, f"Reserve screenshot {file.name}")
    screenshot_id = body["data"]["id"]
    for operation in body["data"]["attributes"]["uploadOperations"]:
        request_headers = {item["name"]: item["value"] for item in operation["requestHeaders"]}
        start = operation["offset"]
        end = start + operation["length"]
        chunk_response = requests.put(operation["url"], headers=request_headers, data=data[start:end], timeout=180)
        if not chunk_response.ok:
            raise RuntimeError(f"Screenshot chunk failed {chunk_response.status_code}: {chunk_response.text[:500]}")
    for attempt in range(12):
        response = api("PATCH", f"/appScreenshots/{screenshot_id}", json={
            "data": {
                "type": "appScreenshots",
                "id": screenshot_id,
                "attributes": {"uploaded": True, "sourceFileChecksum": checksum},
            }
        })
        if response.status_code in (200, 201):
            print(f"Uploaded screenshot: {file.name}")
            return
        print(f"Confirm screenshot {file.name} retry {attempt + 1}/12: {response.status_code}")
        time.sleep(20)
    require_ok(response, f"Confirm screenshot {file.name}")


def cancel_open_submissions(app_id):
    response, body = api_json("GET", f"/apps/{app_id}/reviewSubmissions?limit=20")
    if response.status_code != 200:
        print(f"Could not list review submissions: {response.status_code}")
        return
    for submission in body.get("data", []):
        state = submission.get("attributes", {}).get("state")
        if state in ("READY_FOR_REVIEW", "UNRESOLVED_ISSUES", "WAITING_FOR_REVIEW", "COMPLETING"):
            response = api("PATCH", f"/reviewSubmissions/{submission['id']}", json={
                "data": {
                    "type": "reviewSubmissions",
                    "id": submission["id"],
                    "attributes": {"canceled": True},
                }
            })
            print(f"Canceled review submission {submission['id']}: {response.status_code}")
    time.sleep(20)


def submit_for_review(app_id, version_id):
    cancel_open_submissions(app_id)
    response, body = api_json("POST", "/reviewSubmissions", json={
        "data": {
            "type": "reviewSubmissions",
            "attributes": {"platform": "IOS"},
            "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
        }
    })
    require_ok(response, "Create review submission")
    submission_id = body["data"]["id"]
    for attempt in range(20):
        response = api("POST", "/reviewSubmissionItems", json={
            "data": {
                "type": "reviewSubmissionItems",
                "relationships": {
                    "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": submission_id}},
                    "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}},
                },
            }
        })
        if response.status_code == 201:
            break
        if response.status_code == 409 and "SCREENSHOT_UPLOADS_IN_PROGRESS" in response.text:
            print("Screenshots processing, waiting before retry.")
            time.sleep(60)
            continue
        raise RuntimeError(f"Create review item failed {response.status_code}: {response.text[:2000]}")
    for attempt in range(30):
        response, body = api_json("PATCH", f"/reviewSubmissions/{submission_id}", json={
            "data": {"type": "reviewSubmissions", "id": submission_id, "attributes": {"submitted": True}}
        })
        if response.status_code == 200:
            print(f"Submitted for review: {body['data']['attributes']['state']}")
            return
        print(f"Submit retry {attempt + 1}/30: {response.status_code}")
        time.sleep(60)
    raise RuntimeError(f"Submit review failed {response.status_code}: {response.text[:1000]}")


def main():
    if not KEY_ID or not ISSUER_ID:
        raise RuntimeError("Missing App Store Connect API key id or issuer id.")
    write_key_file()
    metadata = load_metadata()
    app_id = find_app_id()
    if os.environ.get("LIST_BUILDS_ONLY") == "1":
        print_builds(app_id)
        return
    version_id = find_version(app_id)
    update_app_info(app_id, metadata)
    update_version_metadata(version_id, metadata)
    update_review_detail(version_id, metadata)
    upload_screenshots(version_id)
    print("Waiting for screenshot processing before review submission.")
    time.sleep(300)
    build_id = wait_for_latest_build(app_id)
    assign_build(version_id, build_id)
    if os.environ.get("SUBMIT_FOR_REVIEW", "1") == "1":
        submit_for_review(app_id, version_id)
    else:
        print("SUBMIT_FOR_REVIEW is disabled.")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
