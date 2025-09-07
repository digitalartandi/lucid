'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"feed/news.json": "121f0d48038df7d086edcdda11214332",
"feed/studies.json": "b7c97eb42e7d0494205fce20f921a532",
"manifest.json": "22903008be0d9bbd206cdca69aeb0ade",
"main.dart.js": "56918b6001c4386bdb667b9ce1b19c87",
"version.json": "ada863b6a1cab20045c61588e2267ff2",
"assets/NOTICES": "2a62e76d5502984781265a3912e98bc7",
"assets/AssetManifest.json": "2d9dae2bafba0a02970b8db731a20d2c",
"assets/assets/fonts/DMSans-Bold.ttf": "8acaca0f4a787f54a7bd8bcda015a020",
"assets/assets/fonts/DMSans-Light.ttf": "725ab82fd4427c1250416520c49390b8",
"assets/assets/fonts/DMSans-Regular.ttf": "320182a191b787449d409ba2a26ca5bb",
"assets/assets/fonts/DMSans-SemiBold.ttf": "a83b0b6aa717f52ab1bccc578e60e2a2",
"assets/assets/fonts/DMSans-Medium.ttf": "3a1d7ac000ce95357313448adcbdcdaa",
"assets/assets/checklists/pre_night_de.json": "fdb4fb7a84e77e181f5cb321cb6bfc73",
"assets/assets/feed/curated.json": "486b9b9419ea6590ec15778564c5a5f2",
"assets/assets/feed/sources.json": "2fa610337ffb8404e7a9181aed4f2483",
"assets/assets/meditations/tracks/Aurora-Crown.mp3": "f9099223d369360ced2daaf0c1dce705",
"assets/assets/meditations/tracks/Space.mp3": "22088fcea8ff888c3470afe52e66552a",
"assets/assets/meditations/tracks/the-ancient-horizon.mp3": "a6937a7930e9dc74f1063023915afbea",
"assets/assets/meditations/tracks/misty-horizons.mp3": "2dba7aca4fc669c6b38089e34cff7ed4",
"assets/assets/meditations/tracks/ethereal-depths.mp3": "8a31051c31b2bf83fa271072c906dcc7",
"assets/assets/meditations/tracks/celestial-Reverie.mp3": "728b5ca80130dca1eb624727fdc6cda1",
"assets/assets/meditations/tracks/woodland-breathing.mp3": "c322d06003913eec1d15a9e4727756f8",
"assets/assets/meditations/tracks/Sky-Islands-Glide01.mp3": "2e27960393ee27c7104a6b8093076c44",
"assets/assets/meditations/tracks/Arcane-Library.mp3": "f7bb16ca32eaac35280f7a9e3c09d6e3",
"assets/assets/meditations/tracks/moonlit-fjord.mp3": "a8dd5dba8c40734ee107f2009ba7c024",
"assets/assets/meditations/tracks/Harp-of-the-Evergreen02.mp3": "bb3102df8006ffa5612a2e8f786a8679",
"assets/assets/meditations/tracks/Sky-Islands-Glide02.mp3": "ce91fcc227a95ef4ba37ef7f3505f852",
"assets/assets/meditations/tracks/mists-of-eternity.mp3": "0745ad15f3ddfeca260133f81af0dc9b",
"assets/assets/meditations/tracks/Fairy-Forest.mp3": "651545f63b3995bc709f2768c327b8cf",
"assets/assets/meditations/tracks/highlands.mp3": "c4e450817bbad440a304290aaf5bbf84",
"assets/assets/meditations/tracks/handpan-drift.mp3": "b8ead49a2b4244cc76c91aa258f12dd5",
"assets/assets/meditations/tracks/tropic.mp3": "24a50f2aeb60275d929e89d8b9700f46",
"assets/assets/meditations/tracks/oceanic-breath.mp3": "4ea521bc6a962f085aa756a696544608",
"assets/assets/meditations/tracks/Harp-of-the-Evergreen01.mp3": "5f57e227f3a902b9f52b504bb3be8ba5",
"assets/assets/meditations/tracks/lucid-horizon.mp3": "34ceaf139d64677a69e1e7e236a655a8",
"assets/assets/meditations/manifest.json": "44d324d676b9601a0f93f84bbccfeb11",
"assets/assets/meditations/covers/handpan-drift.jpg": "23e1de173675dbddf2644a28ad38908c",
"assets/assets/meditations/covers/Fairy-Forest.jpg": "61dff343964e215f6896d75c92a71cd3",
"assets/assets/meditations/covers/woodland-breathing.jpg": "f641636174966a00a8e9ec2dca463c28",
"assets/assets/meditations/covers/ethereal-depths.jpg": "b12a8987edb98e7c76c31623e7f830c6",
"assets/assets/meditations/covers/the-ancient-horizon.jpg": "6a4c8d7beed56f79ffa63ed7bc53c0a7",
"assets/assets/meditations/covers/lucid-horizon.jpg": "946a5821a5491d50d15df0b4ce71f0b1",
"assets/assets/meditations/covers/Space.jpg": "878d8621621db12c6c9bb9d6b22b0794",
"assets/assets/meditations/covers/oceanic-breath.jpg": "7ae3dc58da1a4d20e9b1e0ed20876e19",
"assets/assets/meditations/covers/Sky-Islands.jpg": "838936b3f2ab59adbd74a901d7c1870a",
"assets/assets/meditations/covers/mists-of-eternity.jpg": "9fbdf74ba9dd8a3d5ac01e8b3720b9ba",
"assets/assets/meditations/covers/celestial-reverie.jpg": "dcb235df6f0e214545f5db42df122a8b",
"assets/assets/meditations/covers/Aurora-Crown.jpg": "3f9085352142655f98242b14130c45b0",
"assets/assets/meditations/covers/misty-horizons.jpg": "a6d775c6fff1464f5dbbe32b81faaa56",
"assets/assets/meditations/covers/moonlit-fjord.jpg": "e87cd4ec7f964f8292ece59e3669aafe",
"assets/assets/meditations/covers/Harp-of-the-Evergreen.jpg": "91f04c9e214ee880d29dd0da5cb7c5d9",
"assets/assets/meditations/covers/tropic.jpg": "eeb44f5b1ed490844a852b4fefadcbab",
"assets/assets/meditations/covers/highlands.jpg": "5ad504f76bed708e0f1cf0965d457cb3",
"assets/assets/meditations/covers/Arcane-Library.jpg": "ee064667974bbea35b43d87fd188eae8",
"assets/assets/icons/feed.svg": "3337b6299872f83b2b2dc9bc0c3d8f86",
"assets/assets/icons/research.svg": "058f20b1db32b3348d39a5a28ca2f054",
"assets/assets/icons/wissen.svg": "324848ca2d40383f0c47844860355988",
"assets/assets/icons/account.svg": "bb8ed9f7e9388e3eff58d95dd377fd8d",
"assets/assets/icons/home.svg": "3bd291062db2a2e84966d09d81ea7ac9",
"assets/assets/quizzes/techniken_de.json": "0e802e209722e21ac80d908826152ac9",
"assets/assets/brand/hero_bg.webp": "277b9bffd4c87b7c70f6ecb193030c0e",
"assets/assets/logo/logo-text.svg": "5c5657aa79c87c7d5833772b22a94f9a",
"assets/assets/logo/logo-signet.svg": "6ea09a1fc42510ffc5d66760846899cc",
"assets/assets/logo/logo-landingpage.svg": "f11b24abc2ed047bf2547320b7772fd1",
"assets/assets/audio/affirmations/ich-handle-mutig.mp3": "cd666dae163136512b4a8942296a18ce",
"assets/assets/audio/affirmations/ich-darf-mich-beruhigen.mp3": "5b5fa0ea80ffd5b70b2e7c4180aba0c1",
"assets/assets/audio/affirmations/ich-bin-dankbar.mp3": "68cbf4290d00e85e222bf3f05aef9f3e",
"assets/assets/audio/affirmations/ich-goenne-mir-pausen.mp3": "df8ead87a3497d6459c71e4baddca1a0",
"assets/assets/audio/affirmations/ich-mache-pausen.mp3": "bfa98de7a7a76996e3ac458100eedeb7",
"assets/assets/audio/affirmations/alternative-sicht.mp3": "191985340784e2e0ca28e57427f98197",
"assets/assets/audio/affirmations/eigenes-tempo.mp3": "cd3f1300db167c3b33f90b9f938ed0c7",
"assets/assets/audio/affirmations/hier-und-jetzt-sicher.mp3": "7b745b28db9f52b599f4ed9ab113f6ab",
"assets/assets/audio/affirmations/machbarer-schritt.mp3": "ff122dd26547f628e73697051f32fb75",
"assets/assets/audio/affirmations/ich-waehle-klare-grenzen.mp3": "e3d3ad02482e4d2769cd1bbf1e51879e",
"assets/assets/audio/affirmations/naehe-und-abstand.mp3": "d294f85fd257cd56401c578f2f17dd38",
"assets/assets/audio/affirmations/verbundenheit-ist-moeglich.mp3": "0c8f82456bcb6031378754c766841b47",
"assets/assets/audio/affirmations/ein-gedanke-ist-kein-befehl.mp3": "a91a6673bb0616b7c7fe73881f927e8a",
"assets/assets/audio/affirmations/klare-Grenzen.mp3": "2edeaaa0f65674eb6567d077b6702ae0",
"assets/assets/audio/affirmations/lernen-verbessern.mp3": "7d1ce09735978cf4e673f33958c44fba",
"assets/assets/audio/affirmations/richtung-meiner-werte.mp3": "12ff834267c9ff73effa108546fbed50",
"assets/assets/audio/affirmations/ich-trenne-Fakten.mp3": "3eba66b482eef324defd18e0cbaecf39",
"assets/assets/audio/affirmations/kleine-gute-entscheidungen.mp3": "cbaf212855a4d63b0ffed9dc9c682b2b",
"assets/assets/audio/affirmations/Ich-behandle-mich-freundlich.mp3": "418b53fff24e84497361f2f31d3d9f5f",
"assets/assets/audio/affirmations/ich-erkenne-meine-staerken.mp3": "334085aa1925dcc76d2178ae8d4a6636",
"assets/assets/audio/affirmations/ich-muss-das-nicht-allein-schaffen.mp3": "e4f886a495f351bc88fbce89dc6cff3b",
"assets/assets/audio/affirmations/ich-kann-stark-fuehlen.mp3": "99d6b16af2196dd66d551405d369ec3a",
"assets/assets/audio/affirmations/Ich-richte-meinen-fokus.mp3": "f0fa7fd722382a81573fd9c3ce99067b",
"assets/assets/audio/affirmations/hilfe-annehmen.mp3": "d15ba6069348d9d038cc714bae262345",
"assets/assets/audio/affirmations/eine-sache-fuer-die-ich-dankbar-bin.mp3": "0cedbabc57a9ea503d7b097fe7956b23",
"assets/assets/audio/affirmations/jederzeit-pause.mp3": "b32a6b47d1f965ae4fc16320f33b66e1",
"assets/assets/audio/affirmations/ich-richte-meine-energie.mp3": "8b4640e9a0bd72d9969934f677cbb299",
"assets/assets/audio/affirmations/faehigkeiten-wachsen.mp3": "d0b230ab4e5030c513cec395d7b0d0d9",
"assets/assets/audio/affirmations/ich-feiere-kleine-erfolge.mp3": "4a3928e1d5123ea887a50138101705f2",
"assets/assets/audio/affirmations/wie-ein-guter-freund.mp3": "cb30eea5cd6625eeec2033d031a81810",
"assets/assets/audio/affirmations/ich-bin-genug.mp3": "594c7cde085b03d7f6a899591a8b87cd",
"assets/assets/audio/affirmations/wahlmoeglichkeiten.mp3": "608044087b0e0d53475a4c59f0fcca73",
"assets/assets/audio/affirmations/mehr-als-gedanken-und-gefuehle.mp3": "988566c0c6e5cd507356e1d0c45e0603",
"assets/assets/audio/affirmations/ich-bin-was-ich-daraus-mache.mp3": "aff55f0a16f0a1512294fa8f32fc5679",
"assets/assets/audio/affirmations/ein-kleiner-machbarer-schritt.mp3": "ea2c49e4c1fc4504fcefb17d0364b5b5",
"assets/assets/audio/affirmations/ich-ube-selbstmitgefuehl.mp3": "d3172e32b2a3f98ca89b24c0307aca54",
"assets/assets/audio/affirmations/ich-bin-belastbar.mp3": "ef712b822134c8f3b5f0a7a7ca7c5c93",
"assets/assets/audio/cues/harp-three-note-arpe02.mp3": "13ada1323e3ac0b188eaec2e850e2d9e",
"assets/assets/audio/cues/fireplace01.mp3": "0900c5bff8e7f1f7187efc517223a3c2",
"assets/assets/audio/cues/meadow-bees03.mp3": "7d9e37ea85c0f0009c072c395c9ac5c0",
"assets/assets/audio/cues/owl-distant04.mp3": "d78ce6fbc0fa7b72ada666fc9fc2d123",
"assets/assets/audio/cues/rain-on-broad-leaf01.mp3": "47eaa303e5106e50ddbc7efcc53ce705",
"assets/assets/audio/cues/water02.mp3": "57efe2ab0da5e60874c69474728b33d3",
"assets/assets/audio/cues/light-rain01.mp3": "1ca0dd35bccfb66abea27d584e93c094",
"assets/assets/audio/cues/very-soft-glockenspiel02.mp3": "28a7d881b5599e110db61e3c44cc6240",
"assets/assets/audio/cues/spacecraft-interior2.mp3": "fc0cd15706ef84d47c2fd51ae7b951ed",
"assets/assets/audio/cues/owl-distant01.mp3": "70b11cf5e4829e649335cf0b12417da0",
"assets/assets/audio/cues/sea01.mp3": "e6afad8b6ee265f8b275a7c875818ab9",
"assets/assets/audio/cues/very-soft-glockenspiel01.mp3": "720ae27ec02581765fc376c0f8b07b8d",
"assets/assets/audio/cues/soft-chim.mp3": "0bef478d01a9c67633ff0809332cd073",
"assets/assets/audio/cues/rain-on-tent%2520tarpaulin2.mp3": "07f89436c42b6771a4f2aaadbba385a5",
"assets/assets/audio/cues/sea02.mp3": "565da8ad7f43b07b5c2819b8355e60cd",
"assets/assets/audio/cues/tuning-fork-A4-style01.mp3": "6cf5abcf796594647e97fa469ec6e043",
"assets/assets/audio/cues/birdsong02.mp3": "4e6a4f9e0eab76f0dcf507cb0128cb8b",
"assets/assets/audio/cues/calm-shoreline01.mp3": "7b4843c35e6b8a28dcc7f241d31f62ef",
"assets/assets/audio/cues/rain-on-broad-leaf02.mp3": "fcc44d9314417068d58ce17ed66198ac",
"assets/assets/audio/cues/owl-distant02.mp3": "304f531b645ba57ad55fa8ced7812264",
"assets/assets/audio/cues/cricket-chorus02.mp3": "eb67249be57a164558948d398cc7437e",
"assets/assets/audio/cues/fireplace02.mp3": "8f46203cb403b9f54f26d3f283018fc4",
"assets/assets/audio/cues/birdsong03.mp3": "8161b19453bef31a1cd6f570886c22cb",
"assets/assets/audio/cues/birdsong04.mp3": "a58af51215b092ca70c8d67e79aa07e8",
"assets/assets/audio/cues/soft-click-to-chime02.mp3": "24c26265b9d2b1d82f5e127aa2524429",
"assets/assets/audio/cues/bowed-glass-harmonic01.mp3": "82cf62a0fedd03324c5fc0b3af832bab",
"assets/assets/audio/cues/cricket-chorus01.mp3": "f708ef0b48d461eb8769f9975dcece57",
"assets/assets/audio/cues/calm-shoreline02.mp3": "7f461d6a4ba2c8052147d80bd81c9430",
"assets/assets/audio/cues/birdsong01.mp3": "9a1a27c5c2b493adb10c086a82dd0220",
"assets/assets/audio/cues/meadow-bees01.mp3": "2993564a73dfe4fcbac605e8b5b8b46f",
"assets/assets/audio/cues/two-note_soft-chime02.mp3": "749ef568fb78141215f0644145385d3c",
"assets/assets/audio/cues/thunder-rumbles03.mp3": "dd27d23578e48d04d106b78e08084899",
"assets/assets/audio/cues/soft-chim02.mp3": "0921ecdea7cd060b87923e30a860db78",
"assets/assets/audio/cues/shallow-creek02.mp3": "0dc9cf1a30adf1de9e8ec268c126f788",
"assets/assets/audio/cues/soft-click-to-chime.mp3": "56f4d3ed3f7df346114bf90faa0897ff",
"assets/assets/audio/cues/water03.mp3": "ff69de1f3bc0d18a6fa2b82125ba4fb5",
"assets/assets/audio/cues/tuning-fork-A4-style02.mp3": "3d1a432bcba2757e5cfbdc68cd059207",
"assets/assets/audio/cues/cat-purring.mp3": "fb1e38b26733efb5341cd59416dea0cc",
"assets/assets/audio/cues/bowed-glass-harmonic02.mp3": "7c36df2b8057d86fb015feb2c276bb6f",
"assets/assets/audio/cues/shallow-creek01.mp3": "24485268fb95ce924cdf44cf4aef2896",
"assets/assets/audio/cues/mountain-ridge-wind02.mp3": "fdf453c59f1f6bf6c2e3b073c800e5ce",
"assets/assets/audio/cues/dripstone-%2520cave02.mp3": "ede436270569fb5080b97a9c46fd5e23",
"assets/assets/audio/cues/two-note-soft-chime01.mp3": "07561bd618e4dee805cd7fe5a50a45a3",
"assets/assets/audio/cues/fireplace03.mp3": "779446974abd1a8ed8ddc14da6df0583",
"assets/assets/audio/cues/pure-sine-tone-ping.mp3": "ec48754735a5d2c39f7a63d42dd744ef",
"assets/assets/audio/cues/meadow-bees02.mp3": "1b164f2359882de4e9d634b7da260e25",
"assets/assets/audio/cues/rain-on-tent%2520tarpaulin.mp3": "0e8db995e97aef118660426f9b7c0b32",
"assets/assets/audio/cues/wind01.mp3": "3efc2b1cf01c78840c7bda3ef03e4305",
"assets/assets/audio/cues/mountain-ridge-wind01.mp3": "2e4d202f71f4ba6e6bd2dda5be6fb23e",
"assets/assets/audio/cues/harp-three-note-arpe01.mp3": "0e7f4b52e5cc76f55bdf94d54010a704",
"assets/assets/audio/cues/Effekt-Click.mp3": "5cb9440fb7faab542e1252869eb3034e",
"assets/assets/audio/cues/dripstone-%2520cave01.mp3": "7d77fc8e68f51d8fb36f3f230de2749b",
"assets/assets/audio/cues/dripstone-%2520cave03.mp3": "5069f7188af3c16e67ed87eeac426e97",
"assets/assets/audio/cues/rain-on-broad-leaf03.mp3": "b645573a9efd6147e5105f07a78364f0",
"assets/assets/audio/cues/single-glass-bell.mp3": "e5962e12e7b2d5c852dba9db81d01673",
"assets/assets/audio/cues/thunder-rumbles01.mp3": "ec2a3444d9ac344ea86b595aed916d04",
"assets/assets/audio/cues/spacecraft-interior3.mp3": "59b69252fe216692ed1816b97fe0ea96",
"assets/assets/audio/cues/spacecraft-interior.mp3": "576f2fe2b3f420c62dd0ffc1b3c2af0b",
"assets/assets/audio/cues/owl-distant03.mp3": "8cd3f0dd394c693a9edf7d3305514b0c",
"assets/assets/audio/cues/mountain-ridge-wind03.mp3": "239737cbc0f15902e549e7f1c29a8434",
"assets/assets/audio/cues/thunder-rumbles02.mp3": "9a62da96fe02d89388f42d1d8c82d510",
"assets/assets/audio/cues/water01.mp3": "f4d32c435c90a523db887964cd4889e6",
"assets/assets/audio/cues/tropical-rainforest.mp3": "45e987e6e087d856963eb06c1d0aa2d9",
"assets/assets/images/cue_categories/landschaft.webp": "979d5ecc5a3a8059d260a2c473a4b0ea",
"assets/assets/images/cue_categories/sonstiges.webp": "a77c6a12a808ee2a5d95e71451e62c3a",
"assets/assets/images/cue_categories/feuer_hoehle.webp": "a77c6a12a808ee2a5d95e71451e62c3a",
"assets/assets/images/cue_categories/instrumente.webp": "b9fec9ee770d508ccc7c3f3677482965",
"assets/assets/images/cue_categories/wetter.webp": "65165ec817dbfb49d4821da551fce997",
"assets/assets/images/cue_categories/weltraum_technik.webp": "eba4d111ded38c328415791199f1a13c",
"assets/assets/images/cue_categories/synth_pings.webp": "0fe259ae52ba85b255c0a19e1d42309a",
"assets/assets/images/cue_categories/wasser.webp": "979d5ecc5a3a8059d260a2c473a4b0ea",
"assets/assets/images/cue_categories/tiere.webp": "118733e3ff41b213785699bcdaad12c5",
"assets/assets/wissen/troubleshooting_de.md": "fe3c7f9ac76ca6651bbff4deab5999fe",
"assets/assets/wissen/glossary_de.md": "17e9358640e483318f46ee59ef71c0ff",
"assets/assets/wissen/glossar_de.md": "cb79df5baeb3f8f1fe5bc5cad2342d31",
"assets/assets/wissen/faq_de.md": "71c4494019e49055123fc7d1dc07905e",
"assets/assets/wissen/quellen_zitate_de.md": "72bddecb1a9fc84ef6ea82f1a650890d",
"assets/assets/wissen/wearables_erkennung_de.md": "407e64f7edd7f47f36c57afc44f39e6b",
"assets/assets/wissen/techniken_de.md": "9322fda9ec332aa46423a175aec73043",
"assets/assets/wissen/neuro_sleep_de.md": "e864a74c4617febfa0977ab893d8a149",
"assets/assets/wissen/albtraeume_irt_de.md": "624121731b7b4650888a3a0bdb89888d",
"assets/assets/wissen/ethik_risiken_de.md": "8bfdb1cb20a366e087c70eb03edac38b",
"assets/assets/wissen/journal_guide_de.md": "ec2c7107f519f1ee66cdf19458590837",
"assets/assets/wissen/grundlagen_de.md": "91f5e474b87c84291b40c3861a9ab553",
"assets/assets/wissen/klartraum_grundlagen_de.md": "020d6cbd63d01a10d4591f340dded04b",
"assets/assets/wissen_en/wearables_detection_en.md": "8174df1f9642e6450cfc4c18f8b9f83a",
"assets/assets/wissen_en/faq_en.md": "8bb656807ff7661f0a0d3654e366f2d4",
"assets/assets/wissen_en/techniques_en.md": "eecf4830f78e8a418979004968c7d0cf",
"assets/assets/wissen_en/citations_en.md": "c370260388cd68de1a79855d3790e565",
"assets/assets/wissen_en/troubleshooting_en.md": "385960ee291ef74d82cb222e1a2f8ff6",
"assets/assets/wissen_en/nightmare_irt_en.md": "e2fe1f5163f5f24075aa302cd0febdbb",
"assets/assets/wissen_en/journal_guide_en.md": "f13b71a6d0dd39c25b8bcd9c8b6800ce",
"assets/assets/wissen_en/ethics_risks_en.md": "bbf38e7cbfc34a574dc3c65bbc0c58e5",
"assets/assets/wissen_en/neuro_sleep_en.md": "f61a662ea85a8a2afd9da0b771b47439",
"assets/assets/wissen_en/glossary_en.md": "e99f8b70f01c15efe3167242fc89e1d7",
"assets/assets/wissen_en/basics_en.md": "1b69c865efc51a2e48f155670575fae5",
"assets/assets/traumreisen/manifest.json": "d9b92d4691c4a175244bddaab8c2572e",
"assets/assets/traumreisen/audio/Nordlichter-Lappland.mp3": "a435059149052db0c7ab3126aae802f9",
"assets/assets/traumreisen/audio/Garten-german.mp3": "11eca340983673ef32652b1b17a1a404",
"assets/assets/traumreisen/audio/Abenteuerreise-ins-All-german.mp3": "f66c1c2af210075c9bf2626803c41768",
"assets/assets/traumreisen/audio/Einsame-Insel-german.mp3": "088d5893c6b6afcd9d3ed96284e045ea",
"assets/assets/traumreisen/audio/Traumreise.mp3": "e29b036ffa1fd091ee8601c1a7fee90b",
"assets/assets/traumreisen/audio/Highlands-german.mp3": "fdc736322c689964e640548ff8bafd01",
"assets/assets/traumreisen/audio/Zauberwald-german.mp3": "fb32edab2d6d56f1d7340f57efa1ee9a",
"assets/assets/traumreisen/audio/Regenwald-german.mp3": "5543758cda6bbb60078d8d18db86f177",
"assets/assets/traumreisen/audio/Flug-ueber-Alpen.mp3": "984363ac4de4e600f1f432f436013c2b",
"assets/assets/traumreisen/images/insel.jpg": "738099f50ad641ecec6ba82098bab273",
"assets/assets/traumreisen/images/zauberwald.jpg": "104a4a66309ce35cf4e2b7241a48688a",
"assets/assets/traumreisen/images/garten.jpg": "c1b7fb90e8be265b6fe1815e66818837",
"assets/assets/traumreisen/images/hypnose.jpg": "64d5b56142b52c6ccfe7b5f512e8592c",
"assets/assets/traumreisen/images/all.jpg": "9aefd84eea7c0f7c4a4c73015df53050",
"assets/assets/traumreisen/images/alpen.jpg": "bc13d7dd796faa33da4b00da76a02a27",
"assets/assets/traumreisen/images/nordlichter.jpg": "dd2f57664ec79ece91110d1a3426879a",
"assets/assets/traumreisen/images/regenwald.jpg": "acdbdcec501c9abacb086e90a02dc999",
"assets/assets/traumreisen/images/highlands.jpg": "4763992641097354ab6011c9481d24c7",
"assets/assets/slider/violette-nebel-galaxie-sterne.webp": "3c9bae46e5906653e3376ad7106ec41e",
"assets/assets/slider/lichttor-in-wolken-goldene-stunde.webp": "eba4d111ded38c328415791199f1a13c",
"assets/assets/slider/felsbogen-am-meer-lichtkranz.webp": "a60d0891dca681793c326e52781c8896",
"assets/assets/slider/grashalme-tau-bokeh-nacht.webp": "cf879754a1239697de0393a6991bdc91",
"assets/assets/slider/wirbelnde-wolken-gruenes-licht.webp": "65165ec817dbfb49d4821da551fce997",
"assets/assets/slider/loops/Loop01.mp4": "10a6b523076f63da59347e6cd2da25c3",
"assets/assets/slider/loops/Loop02.mp4": "bb0d3cf091a1fbb3e53789fb58c6db22",
"assets/assets/slider/makro-bluete-violett-bokeh.webp": "b7291222045945d91af8c415c2597efb",
"assets/assets/slider/kurvenstrasse-hochland-sturmwolke.webp": "ca572aba189985188d73a7a1225b78a0",
"assets/assets/slider/nordlichter-bergsee-panoramablick.webp": "118733e3ff41b213785699bcdaad12c5",
"assets/assets/slider/steinkreis-daemmerung-heide.webp": "59edda431de1321b2ea1a2395827d670",
"assets/assets/slider/sternenhimmel-berglandschaft-blaue-stunde.webp": "c7502c73e1bdb2ed971458605f49d419",
"assets/assets/slider/nacht-am-bergsee-violette-toene.webp": "f7be3e4129bfeaa2904231898b55d87f",
"assets/assets/slider/hirsch-silhouette-mond-nebelhang.webp": "377b3135e086658414552e3899f6b440",
"assets/assets/slider/milchstrasse-ueber-bergspitzen-daemmerung.webp": "77a7d86c4d0822e0385d0da94cdea574",
"assets/assets/slider/pastell-wolkenwellen-abstrakt.webp": "4f9d362b8b35b22190ed570ed8803d14",
"assets/assets/slider/gluehwuermchen-im-gras-nacht.webp": "7e68565106f813aeb5b971f01d40a570",
"assets/assets/slider/mondsichel-ueber-bergkamm-daemmerung.webp": "6189899a21882faad987e63215ea6ab9",
"assets/assets/slider/felsiges-seeufer-blaue-stunde.webp": "ae1f77dcadb31f7f89781e1158fa5616",
"assets/assets/slider/galaxie-nebel-violett-blau.webp": "f970669beb8e285f648d960cfd162763",
"assets/assets/slider/kuestenberge-nebelmeer-tuerkis-daemmerung.webp": "86664315a3ed3bd3277fafe62a67da3e",
"assets/assets/slider/manifest.json": "1de2fa48d0ac8d926c6961fcff60eb05",
"assets/assets/slider/dramatische-sturmwolken-tuerkis-himmel-.webp": "a77c6a12a808ee2a5d95e71451e62c3a",
"assets/assets/slider/sternspur-ueber-waldhang.webp": "f3d5908a90706c16c0564077bc5b4779",
"assets/assets/slider/kosmische-nebelwolke-tuerkis.webp": "2de9b8166e85ec6be8782da45bf7611c",
"assets/assets/slider/nordlichter-hinter-nadelbaeumen-nacht.webp": "8b9fd14515162b5f77373a5b7f1074c1",
"assets/assets/slider/nachtlandschaft-bergkette-sternenband.png": "acd67ae4e1a78012876a3248d94cd3c2",
"assets/assets/slider/pastell-kugeln-bokeh-abstrakt.webp": "07d5464c527a43ac04dca9595db962f5",
"assets/assets/slider/abenddaemmerung-berge-spiegelnder-see.webp": "6e934f2f88a84054793369ade1810df8",
"assets/assets/slider/nordlichter-ueber-felsnadeln.webp": "ec80cf59e8c8c35c50909e157401ece0",
"assets/assets/slider/mondnacht-heidelandschaft-kurviger-weg.webp": "7f34892d10a8a9eda9bfdf4bf923332d",
"assets/assets/slider/nordlichter-bergsee-lichter-am-ufer.webp": "118733e3ff41b213785699bcdaad12c5",
"assets/assets/slider/nebliger-wald-weiher-mystische-stimmung.webp": "b9fec9ee770d508ccc7c3f3677482965",
"assets/assets/slider/milchstrasse-am-bergsee-vertikal.webp": "ba96792bbe8462fa12e0806f6d79971a",
"assets/assets/slider/steinmaennchen-bergwiese-sturmwolken.webp": "47630e0cb21386b6e141435b232eeb7b",
"assets/assets/slider/bauminsel-spiegelung-daemmerung.webp": "7f0ff8bc610df8a66f905ba7d9bd7050",
"assets/assets/slider/kurvenstrasse-tal-goldene-wiesen.webp": "a89318fc56bad3683e99dbc507136f19",
"assets/assets/slider/leuchtendes-gehirn-neuronale-wellen.webp": "79a467de6ff22280ac3db469edf4aa26",
"assets/assets/slider/steilkuste-sonnenuntergangshorizont.webp": "3dc1d11914c673227b1592abdcb96481",
"assets/assets/slider/milchstrasse-ueber-see-und-wald.webp": "99f7a546db4167abf2cf74b8cc279bc9",
"assets/assets/slider/see-und-berge-violette-daemmerung.webp": "78d76d6cdd7fc53eb49d987088c2ba66",
"assets/assets/slider/nordlichter-felsformationen-wolkenmeer.webp": "8406b2274a18c84139f6267c31d60654",
"assets/assets/slider/seidige-farbwellen-abstrakt.webp": "feedba1b7a23833309295d1ecbfcdd1e",
"assets/assets/slider/abstrakte-bluetenblaetter-pastell-lila-orange.webp": "2452ff012e80b29dc5d1203655ff5542",
"assets/assets/slider/sternennacht-silhouette-gebirgskette.webp": "a93284619b8a10c2a4b4068c84ecf026",
"assets/assets/slider/auroraband-gruen-blau-ueber-bergen.webp": "0fe259ae52ba85b255c0a19e1d42309a",
"assets/assets/slider/violetter-sonnenuntergang-ruhiger-see.webp": "5c1cd3927e6b914c28cf8adf109c064b",
"assets/assets/slider/softfocus-blueten-pastellfarben.webp": "4b71be21c870d48204800a56dbd83be4",
"assets/assets/slider/mondsichel-ueber-bergkette-blaue-stunde.webp": "87022e47994c067ef04017a92706980b",
"assets/assets/slider/nachthimmel-farbband-ueber-bergkette.webp": "34a1c4f75d168b1a3533e34f83470929",
"assets/assets/slider/sternhimmel-ueber-einsamen-berg-rosa-horizont.webp": "43fa433a7d069be6f363408671520965",
"assets/assets/slider/polarleuchten-ueber-bergkamm-pastell.webp": "979d5ecc5a3a8059d260a2c473a4b0ea",
"assets/assets/slider/nordlichter-ueber-bergsee-spiegelung.webp": "2e502c44fd1d7063ae807c0fa4e9203e",
"assets/FontManifest.json": "4697519e210eabbbd1fcc84245624f49",
"assets/AssetManifest.bin.json": "b63a1ef8c57f39764bea58a790ff363a",
"assets/AssetManifest.bin": "1e169b65ebb3b21fcd4b621957f73c93",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "5e1a87b3c21639632f40ab6f6c7b80f8",
"flutter_bootstrap.js": "4dee947b729ea32914aecb6492743985",
"index.html": "5a7a79f400543df71d03415c4ec08f68",
"/": "5a7a79f400543df71d03415c4ec08f68"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
