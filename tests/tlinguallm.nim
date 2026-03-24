{.experimental: "strict_funcs".}
import std/unittest
import linguallm

suite "detect":
  test "detect with mock":
    let mock: DetectFn = proc(t: string): Result[Language, BridgeError] {.raises: [].} =
      Result[Language, BridgeError].good(language("en", "English"))
    let r = detect("hello", mock)
    check r.is_good
    check r.val.code == "en"

suite "route":
  test "route known language":
    var rc = new_route_config("default_model", "You are helpful.")
    rc.add_route("de", "german_model", "Du bist hilfreich.")
    let lang = language("de", "German")
    let r = route(lang, rc)
    check not r.fallback
    check r.config.model_path == "german_model"

  test "route unknown fallback":
    let rc = new_route_config("default_model", "prompt")
    let r = route(language("sw", "Swahili"), rc)
    check r.fallback
    check r.config.model_path == "default_model"

suite "translate":
  test "skip translation same language":
    let mock_tr: TranslateFn = proc(t, f, l: string): Result[string, BridgeError] {.raises: [].} =
      Result[string, BridgeError].good("translated")
    let layer = new_translate_layer(mock_tr, "en")
    let r = pre_translate(layer, "hello", language("en", "English"))
    check r.is_good
    check r.val == "hello"

  test "translate different language":
    let mock_tr: TranslateFn = proc(t, f, l: string): Result[string, BridgeError] {.raises: [].} =
      Result[string, BridgeError].good("translated: " & t)
    let layer = new_translate_layer(mock_tr, "en")
    let r = pre_translate(layer, "hola", language("es", "Spanish"))
    check r.is_good
    check r.val == "translated: hola"

suite "session":
  test "query end-to-end":
    let mock_detect: DetectFn = proc(t: string): Result[Language, BridgeError] {.raises: [].} =
      Result[Language, BridgeError].good(language("en", "English"))
    let mock_inf: InferenceFn = proc(p, sp: string): Result[string, BridgeError] {.raises: [].} =
      Result[string, BridgeError].good("answer: " & p)
    let rc = new_route_config("model", "system prompt")
    var s = new_lingua_session(mock_detect, mock_inf, rc)
    let r = s.query("what is nim?")
    check r.is_good
    check r.val == "answer: what is nim?"
    check s.queries == 1
