#!/usr/bin/env python3
"""Generate a typed Dart API layer from the Immich OpenAPI 3.0 specification.

Emits:
  <out>/models.dart   - all reachable DTOs (fromJson / toJson)
  <out>/client.dart   - ImmichApiClient, one method per selected operation
"""
from __future__ import annotations

import json
import keyword
import re
import sys
from pathlib import Path

SPEC_PATH = Path(sys.argv[1])
OUT_DIR = Path(sys.argv[2])
OUT_DIR.mkdir(parents=True, exist_ok=True)

spec = json.loads(SPEC_PATH.read_text())
SCHEMAS: dict = spec.get("components", {}).get("schemas", {})
PATHS: dict = spec.get("paths", {})

# ---------------------------------------------------------------------------
# The operations the mobile client actually drives.  Everything else in the
# (276 operation) spec is admin surface we do not render.
# ---------------------------------------------------------------------------
SELECTED_OPS = [
    # auth
    "login", "logout", "validateAccessToken", "getAuthStatus", "changePassword",
    "signUpAdmin", "setupPinCode", "changePinCode", "resetPinCode",
    "lockAuthSession", "unlockAuthSession",
    "startOAuth", "finishOAuth", "linkOAuthAccount", "unlinkOAuthAccount", "redirectOAuthToMobile",
    # server
    "pingServer", "getAboutInfo", "getServerVersion",
    "getSupportedMediaTypes", "getServerStatistics", "getStorage", "getServerLicense",
    "getVersionCheck", "getVersionHistory",
    # users / config
    "getMyUser", "getMyPreferences", "updateMyPreferences", "getMyCalendarHeatmap",
    "getUser", "searchUsers", "createProfileImage", "deleteProfileImage", "getProfileImage",
    "getUserConfig", "getUserConfigDefaults", "getUserOnboarding", "setUserOnboarding",
    "deleteUserLicense", "setUserLicense",
    "getSessions", "deleteSession", "deleteAllSessions", "createSession",
    "getApiKeys", "createApiKey", "updateApiKey", "deleteApiKey",
    # assets
    "uploadAsset", "checkBulkUpload", "getAssetInfo", "updateAsset", "deleteAssets",
    "getAssetStatistics", "runAssetJobs", "downloadAsset", "viewAsset", "playAssetVideo",
    "getAssetMetadata", "getAssetOcr", "editAsset", "getAssetEdits", "removeAssetEdits",
    "copyAsset", "updateBulkAssetMetadata", "getAssetMetadataByKey", "deleteAssetMetadata",
    "updateAssets",  # bulk-update: favorite/archive/rating/description/location/datetime
    # timeline
    "getTimeBuckets", "getTimeBucket",
    # search
    "searchAssets", "searchSmart", "searchRandom", "getSearchSuggestions",
    "getExploreData", "searchPerson", "searchPlaces", "getAssetsByCity", "searchAssetStatistics",
    # albums
    "getAllAlbums", "createAlbum", "getAlbumInfo", "updateAlbumInfo", "deleteAlbum",
    "addAssetsToAlbum", "removeAssetFromAlbum", "addUsersToAlbum", "removeUserFromAlbum",
    "updateAlbumUser", "getAlbumStatistics", "getAlbumMapMarkers", "addAssetsToAlbums",
    # people / faces
    "getAllPeople", "createPerson", "updatePerson", "updatePeople", "deletePerson",
    "deletePeople", "getPerson", "getPersonThumbnail", "getPersonStatistics",
    "mergePeople", "reassignFaces", "reassignFacesById",
    "getFaces", "createFace", "deleteFace",
    # partners
    "getPartners", "createPartner", "updatePartner", "removePartner",
    # memories
    "searchMemories", "createMemory", "getMemory", "updateMemory", "deleteMemory",
    "addMemoryAssets", "removeMemoryAssets", "memoriesStatistics",
    # trash
    "restoreAssets", "restoreTrash", "emptyTrash",
    # shared links
    "createSharedLink", "getAllSharedLinks", "getSharedLinkById", "updateSharedLink",
    "removeSharedLink", "addSharedLinkAssets", "removeSharedLinkAssets",
    # activities, map, tags, stacks, duplicates, libraries, download
    "getActivities", "createActivity", "deleteActivity", "getActivityStatistics",
    "getMapMarkers", "reverseGeocode",
    "getAllTags", "createTag", "getTagById", "deleteTag", "tagAssets", "untagAssets",
    "upsertTags", "bulkTagAssets",
    "searchStacks", "createStack", "getStack", "deleteStack", "deleteStacks",
    "removeAssetFromStack",
    "getAssetDuplicates", "deleteDuplicate", "deleteDuplicates", "resolveDuplicates",
    "getAllLibraries", "getLibrary", "getLibraryStatistics", "scanLibrary", "createLibrary",
    "downloadArchive", "getDownloadInfo",
    # sync (offline delta sync)
    "getSyncStream", "sendSyncAck", "getSyncAck", "deleteSyncAck",
    # asset files (offline / sidecars)
    "searchAssetFiles", "getAssetFile", "downloadAssetFile",
    # notifications
    "getNotifications", "getNotification", "updateNotification", "deleteNotification",
    "updateNotifications", "deleteNotifications",
    # views / folder
    "getUniqueOriginalPaths", "getAssetsByOriginalPath",
]

# operationId -> (method, path) index
OPS: dict[str, tuple[str, str, dict]] = {}
for _p, _ops in PATHS.items():
    for _m, _op in _ops.items():
        if _m not in ("get", "post", "put", "patch", "delete", "head"):
            continue
        _oid = _op.get("operationId")
        if _oid:
            OPS.setdefault(_oid, (_m.upper(), _p, _op))

MISSING = [o for o in SELECTED_OPS if o not in OPS]
if MISSING:
    print("WARNING: operationIds not found in spec: %s" % MISSING, file=sys.stderr)

# ---------------------------------------------------------------------------
# name helpers
# ---------------------------------------------------------------------------
DART_RESERVED = {
    "abstract", "as", "assert", "async", "await", "break", "case", "catch", "class",
    "const", "continue", "covariant", "default", "deferred", "do", "dynamic", "else",
    "enum", "export", "extends", "extension", "external", "false", "final", "finally",
    "for", "Function", "get", "hide", "if", "implements", "import", "in", "interface",
    "is", "late", "library", "mixin", "new", "null", "on", "operator", "part", "required",
    "rethrow", "return", "set", "show", "static", "super", "switch", "sync", "this",
    "throw", "true", "try", "typedef", "var", "void", "when", "while", "with", "yield",
}


def cls_name(s: str) -> str:
    s = re.sub(r"[^A-Za-z0-9]", "", s)
    return s[0].upper() + s[1:] if s else s


def field_name(s: str) -> str:
    s = re.sub(r"[^A-Za-z0-9_]", "_", s)
    s = re.sub(r"_+", "_", s).strip("_")
    if not s:
        s = "value"
    if s[0].isdigit():
        s = "n" + s
    if s in DART_RESERVED or keyword.iskeyword(s):
        s = s + "_"
    # camelCase the first hump
    return s[0].lower() + s[1:]


def enum_member(s: str) -> str:
    s = re.sub(r"[^A-Za-z0-9_]", "_", s)
    if not s:
        s = "empty"
    if s[0].isdigit():
        s = "n" + s
    if s in DART_RESERVED:
        s = s + "_"
    return s[0].lower() + s[1:]


def ref_name(ref: str) -> str:
    return ref.split("/")[-1]


# ---------------------------------------------------------------------------
# schema -> dart type
# ---------------------------------------------------------------------------
def dart_type(schema: dict | None, nullable_override: bool = False) -> str:
    if schema is None:
        return "dynamic"
    if "$ref" in schema:
        t = cls_name(ref_name(schema["$ref"]))
        return t
    if "allOf" in schema:
        subs = schema["allOf"]
        # a $ref + description/nullable wrapper collapses to the ref
        refs = [s for s in subs if "$ref" in s]
        if len(refs) == 1 and len(subs) <= 2:
            return dart_type(refs[0])
        if refs:
            return dart_type(refs[0])
        return "Map<String, dynamic>"
    if "oneOf" in schema or "anyOf" in schema:
        subs = schema.get("oneOf") or schema.get("anyOf")
        refs = [s for s in subs if "$ref" in s]
        non_null = [s for s in subs if s.get("type") != "null"]
        if len(refs) == 1 and len(subs) <= 2:
            return dart_type(refs[0])
        if len(non_null) == 1:
            return dart_type(non_null[0])
        return "dynamic"
    t = schema.get("type")
    if isinstance(t, list):
        t = next((x for x in t if x != "null"), "string")
    if t == "integer":
        return "int"
    if t == "number":
        return "double"
    if t == "boolean":
        return "bool"
    if t == "array":
        return "List<%s>" % dart_type(schema.get("items") or {})
    if t == "object":
        addl = schema.get("additionalProperties")
        if isinstance(addl, dict) and addl:
            return "Map<String, %s>" % dart_type(addl)
        return "Map<String, dynamic>"
    if t == "string":
        if schema.get("format") in ("binary",):
            return "List<int>"
        return "String"
    return "dynamic"


def is_nullable(schema: dict) -> bool:
    if not schema:
        return True
    if "$ref" in schema:
        return False  # resolved by the referenced class
    if schema.get("nullable"):
        return True
    t = schema.get("type")
    if isinstance(t, list):
        return "null" in t
    for k in ("oneOf", "anyOf"):
        if k in schema:
            return any(s.get("type") == "null" for s in schema[k])
    if "allOf" in schema:
        return any(s.get("nullable") for s in schema["allOf"] if isinstance(s, dict))
    return False


def dart_field_type(schema: dict) -> str:
    t = dart_type(schema)
    if t not in ("dynamic",) and is_nullable(schema):
        return t + "?"
    return t


def collects_refs(schema, acc: set):
    if not isinstance(schema, dict):
        return
    if "$ref" in schema:
        n = ref_name(schema["$ref"])
        if n not in acc:
            acc.add(n)
            if n in SCHEMAS:
                collects_refs(SCHEMAS[n], acc)
        return
    for k in ("allOf", "oneOf", "anyOf"):
        for s in schema.get(k, []) or []:
            collects_refs(s, acc)
    if schema.get("type") == "array" or "items" in schema:
        collects_refs(schema.get("items"), acc)
    if isinstance(schema.get("additionalProperties"), dict):
        collects_refs(schema["additionalProperties"], acc)
    for s in (schema.get("properties") or {}).values():
        collects_refs(s, acc)


# ---------------------------------------------------------------------------
# 1. resolve the reachable schema closure
# ---------------------------------------------------------------------------
needed: set[str] = set()
operations: list[tuple[str, str, dict]] = []
for oid in SELECTED_OPS:
    if oid not in OPS:
        continue
    m, p, op = OPS[oid]
    operations.append((m, p, op))
    for prm in op.get("parameters", []) or []:
        collects_refs(prm.get("schema"), needed)
    rb = op.get("requestBody") or {}
    for ct, c in (rb.get("content") or {}).items():
        collects_refs(c.get("schema"), needed)
    for code, r in (op.get("responses") or {}).items():
        for ct, c in (r.get("content") or {}).items():
            collects_refs(c.get("schema"), needed)

# expand closure (nested refs)
changed = True
while changed:
    changed = False
    for n in list(needed):
        if n in SCHEMAS:
            before = len(needed)
            collects_refs(SCHEMAS[n], needed)
            if len(needed) != before:
                changed = True

enum_schemas: dict[str, dict] = {}
object_schemas: dict[str, dict] = {}
for n in sorted(needed):
    s = SCHEMAS.get(n)
    if not isinstance(s, dict):
        continue
    if s.get("enum") and (s.get("type") == "string" or not s.get("type")):
        enum_schemas[n] = s
    elif s.get("type") == "object" or "properties" in s:
        object_schemas[n] = s
    elif s.get("enum"):
        enum_schemas[n] = s
    elif "$ref" in s and len(s) == 1:
        # pure-ref alias: store raw schema for typedef emission
        object_schemas[n] = s

print("schemas: %d (enums %d, objects %d), operations: %d" % (
    len(needed), len(enum_schemas), len(object_schemas), len(operations)))

# ---------------------------------------------------------------------------
# 2. emit models.dart
# ---------------------------------------------------------------------------
def emit_enum(n: str, s: dict, out: list):
    cn = cls_name(n)
    vals = [str(v) for v in s.get("enum", [])]
    members = []
    seen = {}
    for v in vals:
        m = enum_member(v)
        if m in seen:
            m = m + "_" + str(len([k for k in seen if k.startswith(m)]))
        seen[m] = v
        members.append((m, v))
    out.append("enum %s {" % cn)
    out.append("  swaggerGeneratedUnknown,")
    for m, _v in members:
        out.append("  %s," % m)
    out.append("}")
    out.append("")
    out.append("extension %sExt on %s {" % (cn, cn))
    out.append("  String get value {")
    out.append("    switch (this) {")
    for m, v in members:
        out.append("      case %s.%s:" % (cn, m))
        out.append("        return %s;" % json.dumps(v))
    out.append("      case %s.swaggerGeneratedUnknown:" % cn)
    out.append("        return '';")
    out.append("    }")
    out.append("  }")
    out.append("")
    out.append("}")
    out.append("")
    out.append("%s _%sFromJson(String? v) {" % (cn, cn[0].lower() + cn[1:]))
    out.append("  switch (v) {")
    for m, v in members:
        out.append("    case %s:" % json.dumps(v))
        out.append("      return %s.%s;" % (cn, m))
    out.append("  }")
    out.append("  return %s.swaggerGeneratedUnknown;" % cn)
    out.append("}")
    out.append("")


def parse_expr(t: str, expr: str) -> str:
    """Return a Dart expression converting `expr` (dynamic) into `t`."""
    if t.endswith("?"):
        t = t[:-1]
    if t == "dynamic":
        return expr
    if t == "String":
        return "%s?.toString()" % expr
    if t == "int":
        return "(%s as num?)?.toInt()" % expr
    if t == "double":
        return "(%s as num?)?.toDouble()" % expr
    if t == "bool":
        return "(%s as bool?)" % expr
    if t == "List<int>":
        return "(%s as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()" % expr
    m = re.match(r"^List<(.+)>$", t)
    if m:
        inner = m.group(1)
        if inner == "dynamic":
            return "(%s as List<dynamic>?)" % expr
        return "((%s as List<dynamic>?)?.map((e) => %s).whereType<%s>().toList())" % (
            expr, parse_expr(inner, "e"), inner)
    m = re.match(r"^Map<String, (.+)>$", t)
    if m:
        inner = m.group(1)
        if inner == "dynamic":
            return "(%s as Map<String, dynamic>?)" % expr
        return "((%s as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, %s)))" % (
            expr, parse_expr(inner, "e"))
    # generated class or enum
    base = t[:-1] if t.endswith("?") else t
    if base in enum_schemas:
        return "_%sFromJson(%s?.toString())" % (base[0].lower() + base[1:], expr)
    return "%s.fromJson((%s as Map<String, dynamic>?))" % (base, expr)


def ser_expr(t: str, expr: str) -> str:
    """Return a Dart expression serialising `expr` (typed t) back to JSON."""
    base = t[:-1] if t.endswith("?") else t
    if base in ("String", "int", "double", "bool", "dynamic", "List<int>"):
        return expr
    m = re.match(r"^List<(.+)>$", base)
    if m:
        inner = m.group(1)
        if inner in ("String", "int", "double", "bool", "dynamic"):
            return expr
        return "%s?.map((e) => %s).toList()" % (expr, ser_expr(inner, "e"))
    m = re.match(r"^Map<String, (.+)>$", base)
    if m:
        inner = m.group(1)
        if inner in ("String", "int", "double", "bool", "dynamic"):
            return expr
        return "%s?.map((k, e) => MapEntry(k, %s))" % (expr, ser_expr(inner, "e"))
    if base in enum_schemas:
        return "%s?.value" % expr
    return "%s?.toJson()" % expr


def emit_object(n: str, s: dict, out: list):
    cn = cls_name(n)
    props = s.get("properties") or {}
    required = set(s.get("required") or [])
    fields = []
    for pn in props:
        ps = props[pn] or {}
        t = dart_field_type(ps)
        fn = field_name(pn)
        # Every field is nullable: the generated `const X()` factory must stay
        # valid, and the server omits optional properties unpredictably.
        ft = t if t.endswith("?") else t + "?"
        fields.append((fn, ft, pn, ps, False))
    out.append("class %s {" % cn)
    for fn, ft, pn, ps, req in fields:
        out.append("  final %s %s;" % (ft, fn))
    out.append("")
    out.append("  const %s({" % cn)
    for fn, ft, pn, ps, req in fields:
        out.append("    this.%s," % fn)
    out.append("  });")
    out.append("")
    out.append("  factory %s.fromJson(Map<String, dynamic>? json) {" % cn)
    out.append("    if (json == null) return const %s();" % cn)
    out.append("    return %s(" % cn)
    for fn, ft, pn, ps, req in fields:
        out.append("      %s: %s," % (fn, parse_expr(ft, "json[%s]" % json.dumps(pn))))
    out.append("    );")
    out.append("  }")
    out.append("")
    out.append("  Map<String, dynamic> toJson() => {")
    for fn, ft, pn, ps, req in fields:
        out.append("    if (%s != null) %s: %s," % (fn, json.dumps(pn), ser_expr(ft, fn)))
    out.append("  };")
    out.append("")
    out.append("  %s copyWith({" % cn)
    for fn, ft, pn, ps, req in fields:
        out.append("    %s %s," % (ft, fn))
    out.append("  }) {")
    out.append("    return %s(" % cn)
    for fn, ft, pn, ps, req in fields:
        out.append("      %s: %s ?? this.%s," % (fn, fn, fn))
    out.append("    );")
    out.append("  }")
    out.append("")
    out.append("  @override")
    out.append("  String toString() => jsonEncode(toJson());")
    out.append("}")
    out.append("")


models: list[str] = [
    "// ---------------------------------------------------------------------------",
    "// GENERATED FILE - do not edit by hand.",
    "// Source: immich-app/immich open-api/immich-openapi-specs.json (%s)" % (
        spec.get("info", {}).get("version", "?")),
    "// Regenerate with: python3 tools/generate_api.py",
    "// ---------------------------------------------------------------------------",
    "",
    "import 'dart:convert';",
    "",
    "/// Marker for server versions whose payloads this client understands.",
    "const String kGeneratedFromImmichVersion = %s;" % json.dumps(
        str(spec.get("info", {}).get("version", ""))),
    "",
]

# Collect pure-$ref alias schemas (not emitted as classes)
alias_schemas = {}
for n in list(object_schemas.keys()):
    props = object_schemas[n]
    keys = list(props.keys())
    if keys == ['$ref']:
        target = cls_name(ref_name(props['$ref']))
        alias_schemas[n] = target
        del object_schemas[n]

for n in sorted(enum_schemas):
    emit_enum(n, enum_schemas[n], models)
for n, target in sorted(alias_schemas.items()):
    models.append("/// Alias for [%s]." % target)
    models.append("typedef %s = %s;" % (cls_name(n), target))
    models.append("")
for n in sorted(object_schemas):
    emit_object(n, object_schemas[n], models)

(OUT_DIR / "models.dart").write_text("\n".join(models))
print("wrote models.dart: %d lines" % len(models))

# ---------------------------------------------------------------------------
# 3. emit client.dart
# ---------------------------------------------------------------------------
def response_type(op: dict) -> str:
    for code in ("200", "201", "202", "204"):
        r = (op.get("responses") or {}).get(code)
        if not r:
            continue
        for ct, c in (r.get("content") or {}).items():
            if "application/json" in ct:
                return dart_type(c.get("schema"))
    return "void"


def opt(t: str) -> str:
    """Dart named parameters are optional by default; make the type nullable."""
    return t if t.endswith("?") or t == "dynamic" else t + "?"


def dart_method_name(oid: str) -> str:
    return oid[0].lower() + oid[1:]


def path_to_url(path: str) -> str:
    return "'%s'" % path.replace("{", "${").replace("}", "}")


client: list[str] = [
    "// ---------------------------------------------------------------------------",
    "// GENERATED FILE - do not edit by hand.",
    "// Source: immich-app/immich open-api/immich-openapi-specs.json (%s)" % (
        spec.get("info", {}).get("version", "?")),
    "// ---------------------------------------------------------------------------",
    "",
    "import 'dart:convert';",
    "import 'dart:io';",
    "import 'dart:typed_data';",
    "",
    "import 'package:dio/dio.dart';",
    "",
    "import 'models.dart';",
    "",
    "typedef Json = Map<String, dynamic>;",
    "",
    "/// Thrown for every non-2xx answer from an Immich server.",
    "class ImmichApiException implements Exception {",
    "  final int? statusCode;",
    "  final String message;",
    "  final dynamic body;",
    "  const ImmichApiException(this.message, {this.statusCode, this.body});",
    "  @override",
    "  String toString() => 'ImmichApiException($statusCode): $message';",
    "}",
    "",
    "/// Typed, dependency-free client for the Immich REST API.",
    "///",
    "/// Every method mirrors one operation of the published OpenAPI document;",
    "/// `baseUrl` must include the `/api` prefix (e.g. `https://host/api`).",
    "class ImmichApiClient {",
    "  final Dio _dio;",
    "  String baseUrl;",
    "  String? accessToken;",
    "",
    "  ImmichApiClient({",
    "    required this.baseUrl,",
    "    this.accessToken,",
    "    Dio? dio,",
    "    Duration connectTimeout = const Duration(seconds: 30),",
    "    Duration receiveTimeout = const Duration(seconds: 120),",
    "  }) : _dio = dio ??",
    "            Dio(BaseOptions(",
    "          connectTimeout: connectTimeout,",
    "          receiveTimeout: receiveTimeout,",
    "          responseType: ResponseType.json,",
    "        ));",
    "",
    "  Dio get dio => _dio;",
    "",
    "  Options _opts({ResponseType? responseType, Map<String, dynamic>? extra}) => Options(",
    "    responseType: responseType,",
    "    extra: extra,",
    "  );",
    "",
]

# The client needs an injected interceptor for auth headers / custom headers; we
# expose `dio` so the app can add them, and set the bearer on each request here.
def emit_operation(m: str, p: str, op: dict, out: list):
    oid = op["operationId"]
    name = dart_method_name(oid)
    params = op.get("parameters") or []
    path_params = [x for x in params if x.get("in") == "path"]
    query_params = [x for x in params if x.get("in") == "query"]
    rb = op.get("requestBody") or {}
    body_content = rb.get("content") or {}
    is_multipart = any("multipart/form-data" in k for k in body_content)
    json_body = None
    for k, v in body_content.items():
        if "application/json" in k:
            json_body = v.get("schema")
    rt = response_type(op)

    args: list[str] = []
    for prm in path_params:
        t = dart_field_type(prm.get("schema"))
        base = t if not t.endswith("?") else "String"
        pn = field_name(prm["name"])
        if prm.get("required"):
            args.append("required %s %s," % (base, pn))
        else:
            args.append("%s %s," % (opt(base), pn))
    for prm in query_params:
        t = dart_field_type(prm.get("schema"))
        pn = field_name(prm["name"])
        args.append("%s %s," % (opt(t), pn))
    if json_body is not None:
        bt = dart_field_type(json_body)
        args.append("%s body," % opt(bt))
    if is_multipart:
        # Only the upload endpoint is multipart; hand-written below.
        return
    if args:
        out.append("  Future<%s> %s({" % (rt, name))
        for a in args:
            out.append("    " + a)
        out.append("  }) async {")
    else:
        out.append("  Future<%s> %s() async {" % (rt, name))
    q = []
    for prm in query_params:
        pn = field_name(prm["name"])
        pname = prm["name"]
        t = dart_field_type(prm.get("schema"))
        base = t[:-1] if t.endswith("?") else t
        if base in enum_schemas:
            q.append("      if (%s != null) '%s': %s.value," % (pn, pname, pn))
        elif base.startswith("List<") and base not in ("List<String>",):
            q.append("      if (%s != null) '%s': %s.map((e) => %s).toList()," % (
                pn, pname, pn, ser_expr(base[5:-1], "e")))
        elif base == "DateTime":
            q.append("      if (%s != null) '%s': %s.toUtc().toIso8601String()," % (pn, pname, pn))
        elif base == "bool":
            q.append("      if (%s != null) '%s': %s," % (pn, pname, pn))
        else:
            q.append("      if (%s != null) '%s': %s," % (pn, pname, pn))
    if q:
        out.append("    final query = <String, dynamic>{")
        out.extend(q)
        out.append("    };")
    else:
        out.append("    const query = <String, dynamic>{};")
    url = path_to_url(p)
    call = "    final res = await _dio.fetch<dynamic>("
    out.append("    final res = await _request(")
    out.append("      %s," % json.dumps(m))
    out.append("      %s," % url)
    out.append("      queryParameters: query,")
    if json_body is not None:
        bt = dart_field_type(json_body)
        base = bt[:-1] if bt.endswith("?") else bt
        if base.startswith("Map<"):
            out.append("      data: body,")
        else:
            out.append("      data: %s," % ser_expr(base, "body"))
    if rt == "void":
        out.append("      responseType: ResponseType.plain,")
    out.append("    );")
    if rt == "void":
        out.append("    return;")
    else:
        base = rt
        if base.startswith("List<"):
            inner = base[5:-1]
            out.append("    final raw = res.data;")
            out.append("    if (raw is List) {")
            out.append("      return raw.map((e) => %s).toList();" % parse_expr(inner, "e"))
            out.append("    }")
            out.append("    if (raw is Map && raw['items'] is List) {")
            out.append("      final items = raw['items'] as List;")
            out.append("      return items.map((e) => %s).toList();" % parse_expr(inner, "e"))
            out.append("    }")
            out.append("    return <Never>[] as List<%s>;" % inner)
        elif base == "String":
            out.append("    return res.data?.toString() ?? '';")
        elif base in ("int", "double", "bool"):
            out.append("    return (res.data as %s);" % base)
        elif base == "Map<String, dynamic>":
            out.append("    return Map<String, dynamic>.from(res.data as Map);")
        elif base.startswith("Map<"):
            out.append("    return %s;" % parse_expr(base, "res.data"))
        else:
            out.append("    final raw = res.data;")
            out.append("    if (raw is List<int>) {")
            out.append("      return %s.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);" % base)
            out.append("    }")
            if base in enum_schemas:
                out.append("    return _%sFromJson(raw?.toString());" % (base[0].lower() + base[1:]))
            else:
                out.append("    return %s;" % parse_expr(base, "raw"))
    out.append("  }")
    out.append("")


# request plumbing + binary helpers are appended to the class body
client.append("  Future<Response<dynamic>> _request(")
client.append("    String method,")
client.append("    String path,")
client.append("    {Map<String, dynamic>? queryParameters,")
client.append("    dynamic data,")
client.append("    ResponseType? responseType,")
client.append("    Options? options,")
client.append("    ProgressCallback? onSendProgress,")
client.append("    CancelToken? cancelToken}) async {")
client.append("    final uri = Uri.parse('$baseUrl$path').replace(")
client.append("      queryParameters: (queryParameters ?? const {})")
client.append("          .map((k, v) => MapEntry(k, v?.toString()))")
client.append("          .cast<String, dynamic>(),")
client.append("    );")
client.append("    try {")
client.append("      return await _dio.fetch<dynamic>(")
client.append("        RequestOptions(")
client.append("          method: method,")
client.append("          path: path,")
client.append("          baseUrl: baseUrl,")
client.append("          queryParameters: (queryParameters ?? const {})..removeWhere((k, v) => v == null),")
client.append("          data: data,")
client.append("          responseType: responseType ?? ResponseType.json,")
client.append("          onSendProgress: onSendProgress,")
client.append("          cancelToken: cancelToken,")
client.append("          headers: {")
client.append("            if (accessToken != null) 'Authorization': 'Bearer $accessToken',")
client.append("          },")
client.append("        ),")
client.append("      );")
client.append("    } on DioException catch (e) {")
client.append("      throw ImmichApiException(")
client.append("        e.response?.data is Map ? (e.response!.data['message']?.toString() ??")
client.append("            e.message ??")
client.append("            'request failed') : (e.message ?? 'request failed'),")
client.append("        statusCode: e.response?.statusCode,")
client.append("        body: e.response?.data,")
client.append("      );")
client.append("    }")
client.append("  }")
client.append("")

# ---- binary helpers (thumbnail / original / video / profile image) ----------
client.append("  /// Raw bytes of any authenticated Immich path (thumbnails, originals...).")
client.append("  Future<Uint8List> getBytes(")
client.append("    String path, {")
client.append("    Map<String, dynamic>? queryParameters,")
client.append("    Options? options,")
client.append("    CancelToken? cancelToken,")
client.append("  }) async {")
client.append("    final res = await _request('GET', path,")
client.append("        queryParameters: queryParameters,")
client.append("        responseType: ResponseType.bytes,")
client.append("        options: options,")
client.append("        cancelToken: cancelToken);")
client.append("    final d = res.data;")
client.append("    if (d is Uint8List) return d;")
client.append("    if (d is List<int>) return Uint8List.fromList(d);")
client.append("    throw const ImmichApiException('expected binary response');")
client.append("  }")
client.append("")
client.append("  /// Downloads to a file, reporting progress in [0..1].")
client.append("  Future<void> downloadToFile(")
client.append("    String path,")
client.append("    String savePath, {")
client.append("    Map<String, dynamic>? queryParameters,")
client.append("    void Function(int received, int total)? onProgress,")
client.append("    CancelToken? cancelToken,")
client.append("  }) async {")
client.append("    final uri = Uri.parse('$baseUrl$path').replace(")
client.append("      queryParameters: (queryParameters ?? const {})")
client.append("          .map((k, v) => MapEntry(k, v?.toString())),")
client.append("    );")
client.append("    try {")
client.append("      await _dio.downloadUri(uri, savePath,")
client.append("          cancelToken: cancelToken,")
client.append("          onReceiveProgress: onProgress,")
client.append("          options: Options(headers: {")
client.append("            if (accessToken != null) 'Authorization': 'Bearer $accessToken',")
client.append("          }));")
client.append("    } on DioException catch (e) {")
client.append("      throw ImmichApiException(e.message ?? 'download failed',")
client.append("          statusCode: e.response?.statusCode);")
client.append("    }")
client.append("  }")
client.append("")

client.append("  /// Uploads one asset (multipart/form-data, mirrors `POST /assets`).")
client.append("  Future<AssetMediaResponseDto> uploadAsset(")
client.append("    Uint8List bytes, {")
client.append("    required String filename,")
client.append("    required DateTime fileCreatedAt,")
client.append("    required DateTime fileModifiedAt,")
client.append("    String? assetDataContentType,")
client.append("    String? deviceAssetId,")
client.append("    String? deviceId,")
client.append("    String? duration,")
client.append("    bool? isFavorite,")
client.append("    bool? isArchived,")
client.append("    String? livePhotoVideoId,")
client.append("    String? sidecarData,")
client.append("    double? latitude,")
client.append("    double? longitude,")
client.append("    void Function(int, int)? onSendProgress,")
client.append("    CancelToken? cancelToken,")
client.append("  }) async {")
client.append("    final form = FormData.fromMap({")
client.append("      'assetData': MultipartFile.fromBytes(bytes,")
client.append("          filename: filename,")
client.append("          contentType: assetDataContentType == null")
client.append("              ? null")
client.append("              : DioMediaType.parse(assetDataContentType)),")
client.append("      'deviceAssetId': deviceAssetId ?? 'flutter-$filename',")
client.append("      'deviceId': deviceId ?? 'flutter',")
client.append("      'fileCreatedAt': fileCreatedAt.toUtc().toIso8601String(),")
client.append("      'fileModifiedAt': fileModifiedAt.toUtc().toIso8601String(),")
client.append("      'filename': filename,")
client.append("      if (duration != null) 'duration': duration,")
client.append("      if (isFavorite != null) 'isFavorite': isFavorite ? 'true' : 'false',")
client.append("      if (isArchived != null) 'isArchived': isArchived ? 'true' : 'false',")
client.append("      if (livePhotoVideoId != null) 'livePhotoVideoId': livePhotoVideoId,")
client.append("      if (sidecarData != null)")
client.append("        'sidecarData': MultipartFile.fromBytes(utf8.encode(sidecarData),")
client.append("            filename: 'sidecar.xmp'),")
client.append("      if (latitude != null) 'latitude': latitude.toString(),")
client.append("      if (longitude != null) 'longitude': longitude.toString(),")
client.append("    });")
client.append("    final res = await _request('POST', '/assets',")
client.append("        data: form,")
client.append("        onSendProgress: onSendProgress,")
client.append("        cancelToken: cancelToken);")
client.append("    return AssetMediaResponseDto.fromJson(res.data as Map<String, dynamic>);")
client.append("  }")
client.append("")

for m, p, op in operations:
    if op["operationId"] == "uploadAsset":
        continue  # hand-written multipart variant above
    emit_operation(m, p, op, client)

client.append("}")
(OUT_DIR / "client.dart").write_text("\n".join(client))
print("wrote client.dart: %d lines" % len(client))
