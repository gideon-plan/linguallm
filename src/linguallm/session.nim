## session.nim -- Combined lingua + llama session.
{.experimental: "strict_funcs".}
import basis/code/choice, detect, route, translate

type
  InferenceFn* = proc(prompt: string, system_prompt: string): Choice[string] {.raises: [].}

  LinguaLlmSession* = object
    detect_fn*: DetectFn
    inference_fn*: InferenceFn
    route_config*: RouteConfig
    translate_layer*: TranslateLayer
    use_translation*: bool
    queries*: int

proc new_lingua_session*(detect_fn: DetectFn, inference_fn: InferenceFn,
                         route_config: RouteConfig,
                         translate_layer: TranslateLayer = TranslateLayer(),
                         use_translation: bool = false): LinguaLlmSession =
  LinguaLlmSession(detect_fn: detect_fn, inference_fn: inference_fn,
                    route_config: route_config, translate_layer: translate_layer,
                    use_translation: use_translation)

proc query*(s: var LinguaLlmSession, text: string): Choice[string] =
  inc s.queries
  let lang = detect(text, s.detect_fn)
  if lang.is_bad: return bad[string](lang.err)
  let routed = route(lang.val, s.route_config)
  var prompt = text
  if s.use_translation:
    let translated = pre_translate(s.translate_layer, text, lang.val)
    if translated.is_bad: return bad[string](translated.err)
    prompt = translated.val
  let response = s.inference_fn(prompt, routed.config.system_prompt)
  if response.is_bad: return response
  if s.use_translation:
    post_translate(s.translate_layer, response.val, lang.val)
  else:
    response
